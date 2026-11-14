# SESION DE LABORATORIO N° 03: Construyendo una aplicacion con una base de datos documental

## OBJETIVOS
  * Comprender como se construyen aplicaciones con bases de datos documentales.

## REQUERIMIENTOS
  * Conocimientos: 
    - Conocimientos básicos de administración de base de datos.
    - Conocimientos básicos de SQL.
  * Hardware:
    - Virtualization activada en el BIOS..
    - CPU SLAT-capable feature.
    - Al menos 4GB de RAM.
  * Software:
    - Windows 10 64bit: Pro, Enterprise o Education (1607 Anniversary Update, Build 14393 o Superior)
    - Docker Desktop 
    - Powershell versión 7.x
    - Gestores de paquetes: Winget, Choco o Scoop
    - Node Version Manager 1.11 (winget install nvm)

## CONSIDERACIONES INICIALES
  * Clonar el repositorio mediante git para tener los recursos necesarios.
    
## DESARROLLO

1. Iniciar la aplicación Powershell o Windows Terminal en modo administrador. 
2. Copiar la aplicación desarrollada en el Laboratorio 06 (NestJs + Postgres). 
3. En el Terminal, ejecutar el siguiente comando para instalar las dependencias necesarias para el funcionamiento del proyecto.
```Bash
npm i winston winston-mongodb @nestjs/mongoose mongodb
```
4. En el Terminal, ejecutar los siguientes comandos para crear un nuevo modulo y servicio logger.
```Bash
nest g module logger
nest g service logger --no-spec
```  
5. Iniciar Visual Studio Code apuntando a la carpeta recien creada, o desde el terminal ejecutar el comando `code .` para iniciarlo. 
6. En Visual Studio Code, crear el archivo winston.config.ts dentro la ruta src\logger con el siguiente contenido:
```Typescript
import { createLogger, format, transports } from "winston";
import "winston-mongodb";

export const logger = createLogger({
  level: 'info',
  format: format.combine(
    format.timestamp(), // Add a timestamp to MongoDB logs
    format.json(), // Use JSON format for MongoDB logs
  ),
  transports: [
    new transports.MongoDB({
      level: 'info',
      db: process.env.MONGOURL || 'mongodb://upt:upt.2023@localhost/logdb?authSource=admin',
      collection: 'logs',
    }),
  ],
});
```  
7. En Visual Studio Code, dentro la ruta src\logger ubicar y modificar los siguientes archivos con el siguiente contenido:
> logger.module.ts
```Typescript
import { Module } from '@nestjs/common';
import { LoggerService } from './logger.service';
@Module({
  providers: [LoggerService]
})
export class LoggerModule {}
```  
> logger.service.ts
```Typescript
import { Injectable } from '@nestjs/common';
import { logger } from './winston.config';

@Injectable()
export class LoggerService {
  log(message: string, context?: string) {
    logger.info(message, { context });
  }

  error(message: string, trace: string, context?: string) {
    logger.error(message, { context, trace });
  }

  warn(message: string, context?: string) {
    logger.warn(message, { context });
  }

  debug(message: string, context?: string) {
    logger.debug(message, { context });
  }
}
```
8. En Visual Studio Code, dentro la ruta src\tarjetas ubicar y modificar los siguientes archivos con el siguiente contenido:
> tarjetas.controller.ts
```Typescript
import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { TarjetasService } from './tarjetas.service';
import { CreateTarjetaDto } from './dto/create-tarjeta.dto';
import { UpdateTarjetaDto } from './dto/update-tarjeta.dto';
import { LoggerService } from '../logger/logger.service';

@Controller('tarjetas')
export class TarjetasController {
  constructor(
    private readonly tarjetasService: TarjetasService,
    private readonly logger: LoggerService
  ) {}

  @Post()
  create(@Body() createTarjetaDto: CreateTarjetaDto) {
    this.logger.log('This trigger a create request.','TarjetasController');
    return this.tarjetasService.create(createTarjetaDto);
  }

  @Get()
  findAll() {
    this.logger.log('This trigger a findAll request.','TarjetasController');
    return this.tarjetasService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    this.logger.log('This trigger a findOne request.','TarjetasController');
    return this.tarjetasService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateTarjetaDto: UpdateTarjetaDto) {
    this.logger.log('This trigger a update request.','TarjetasController');
    return this.tarjetasService.update(+id, updateTarjetaDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    this.logger.log('This trigger a delete request.','TarjetasController');
    return this.tarjetasService.remove(+id);
  }
}
```  
> tarjetas.module.ts
```Typescript
import { Module } from '@nestjs/common';
import { TarjetasService } from './tarjetas.service';
import { TarjetasController } from './tarjetas.controller';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { Tarjeta } from './entities/tarjeta.entity';
import { LoggerModule } from 'src/logger/logger.module';
import { LoggerService } from 'src/logger/logger.service';

@Module({
  imports: [MikroOrmModule.forFeature([Tarjeta]),
            LoggerModule],
  controllers: [TarjetasController],
  providers: [TarjetasService, LoggerService],
})
export class TarjetasModule {}
```  
8. En Visual Studio Code, dentro la ruta src modificar el archivo app.module.ts con el siguiente contenido:
```Typescript
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TarjetasModule } from './tarjetas/tarjetas.module';
import { MikroOrmModule } from '@mikro-orm/nestjs';
import { LoggerModule } from './logger/logger.module';
import { LoggerService } from './logger/logger.service';

@Module({
  controllers: [AppController],
  providers: [AppService, LoggerService],
  imports: [TarjetasModule, MikroOrmModule.forRoot(), LoggerModule],
})
export class AppModule {}
```
  
9. En Visual Studio Code, en la raiz del proyecto modificar el archivo docker-compose.yml, con el siguiente contenido:
> docker-compose.yml
```Yaml
version: '3.1'

services:

  db:
    container_name: db
    image: postgres
    restart: always
    ports:
      - 5432:5432    
    environment:
      POSTGRES_PASSWORD: upt.2023

  adminer:
    image: adminer
    restart: always
    ports:
      - 9090:8080

  mongo:
    container_name: mongo
    image: mongo
    restart: always
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: upt
      MONGO_INITDB_ROOT_PASSWORD: upt.2023

  mongo-express:
    image: mongo-express
    restart: always
    ports:
      - 8081:8081
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: upt
      ME_CONFIG_MONGODB_ADMINPASSWORD: upt.2023
      ME_CONFIG_MONGODB_URL: mongodb://upt:upt.2023@mongo:27017/

  api:
    container_name: api
    build: .
    ports:
      - '9191:3000'
    environment:
      - DBHOST=db
      - MONGOURL=mongodb://upt:upt.2023@mongo/logdb?authSource=admin
    depends_on:
      - db
      - mongo
```  
12. En el terminal, ejecutar el siguiente comando para construir el contenedor correspondiente de la aplicación.
```Bash
docker-compose up -d
```
13. Finalmente en el terminal, esperar 30 segundos y ejecutar el siguiente comando para realizar la migración de la base de datos necesaria para que la aplicación funcione.
```Bash
docker-compose run --rm api sh -c "npx mikro-orm migration:create && npx mikro-orm migration:up"
docker-compose restart api
```
14. En un navegador de internet, colocar la dirección http://localhost:9191/api para verificar que la apicación se ejecuta correctamente.
![image](https://github.com/UPT-FAING-EPIS/lab_bd_relacional_06/assets/10199939/ec935cc2-ef31-4745-8197-4734fab26687)
> Utilice los comandos post, put get y delete de Swagger para gestionar tarjetas y generar trafico en la aplicación.

15. En un navegador de intenet, colocar la direccion http://localhost:8081/, usuario: admin, password: pass, para verificar que los logs estan siendo generados en la base de datos mongo LogDb.
![image](https://github.com/UPT-FAING-EPIS/lab_bd_no_relacional_04/assets/10199939/42c6cfc6-cce7-4ae2-8beb-d4dac6400934)
![image](https://github.com/UPT-FAING-EPIS/lab_bd_no_relacional_04/assets/10199939/99d50288-f548-4b13-8bdf-5f290f262dfe)
![image](https://github.com/UPT-FAING-EPIS/lab_bd_no_relacional_04/assets/10199939/2d0529a5-162f-4436-9029-7a371502be7f)

---
## Actividades Encargadas
1. Implementar en la clase tarjetas.controller el manejo de excepciones que utilice el metodo error de la clase logger.
2. Genere el archivo main.tf dentro de la carpeta infra, para crear mediante Terraform la infrastructura, en MongoDB Atlas y el backend en un servicio Azure AppService u otro servicio Saas que maneje contenedores
3. Genere la automatizacion infra.yml, que despliegue la infraestrutura.
4. Genere la automatización deploydb.yml, que permita cargar datos en su base de datos Redis.
5. Genere la automatizacion buildimage.yml para construir la imagen y publicarla como paquete en su repositorio.
6. Genere la automatizacion deployimage.yml que despliege la imagen previamente publicada en el servicio Web que maneje contenedores.
