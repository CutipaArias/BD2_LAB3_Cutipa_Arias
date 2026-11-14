terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.15"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

variable "prefix" {
  type    = string
  default = "upt-tarjetas-lab03"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "atlas_public_key" {
  type = string
}

variable "atlas_private_key" {
  type      = string
  sensitive = true
}

variable "atlas_org_id" {
  type = string
}

variable "atlas_region" {
  type    = string
  default = "US_EAST_2"
}

variable "mongo_username" {
  type    = string
  default = "loguser"
}

variable "pg_username" {
  type    = string
  default = "pgadmin"
}

variable "pg_password" {
  type      = string
  sensitive = true
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "registry_username" {
  type = string
}

variable "registry_password" {
  type      = string
  sensitive = true
}

resource "random_password" "mongo" {
  length  = 24
  special = false
}

resource "mongodbatlas_project" "project" {
  name   = var.prefix
  org_id = var.atlas_org_id
}

resource "mongodbatlas_cluster" "cluster" {
  project_id                  = mongodbatlas_project.project.id
  name                        = "logs-cluster"
  provider_name               = "TENANT"
  backing_provider_name       = "AZURE"
  provider_region_name        = var.atlas_region
  provider_instance_size_name = "M0"
}

resource "mongodbatlas_database_user" "user" {
  project_id         = mongodbatlas_project.project.id
  username           = var.mongo_username
  password           = random_password.mongo.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "logdb"
  }

  depends_on = [mongodbatlas_cluster.cluster]
}

resource "mongodbatlas_project_ip_access_list" "all" {
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0"
  comment    = "Acceso desde App Service y GitHub Actions"
}

locals {
  mongo_srv = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
  mongo_uri = "${replace(local.mongo_srv, "mongodb+srv://", "mongodb+srv://${var.mongo_username}:${random_password.mongo.result}@")}/logdb?retryWrites=true&w=majority"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}"
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "${var.prefix}-pg"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  administrator_login    = var.pg_username
  administrator_password = var.pg_password
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  zone                   = "1"
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "tarjetasdb"
  server_id = azurerm_postgresql_flexible_server.pg.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "api" {
  name                = "${var.prefix}-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true
    application_stack {
      docker_image_name        = "${var.image_name}:${var.image_tag}"
      docker_registry_url      = "https://ghcr.io"
      docker_registry_username = var.registry_username
      docker_registry_password = var.registry_password
    }
  }

  app_settings = {
    WEBSITES_PORT = "3000"
    DBHOST        = azurerm_postgresql_flexible_server.pg.fqdn
    DBUSER        = var.pg_username
    DBPASSWORD    = var.pg_password
    DBNAME        = azurerm_postgresql_flexible_server_database.db.name
    DBSSL         = "true"
    MONGOURL      = local.mongo_uri
  }
}

output "pg_host" {
  value = azurerm_postgresql_flexible_server.pg.fqdn
}

output "mongo_uri" {
  value     = local.mongo_uri
  sensitive = true
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.api.default_hostname}/api"
}

output "webapp_name" {
  value = azurerm_linux_web_app.api.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}
