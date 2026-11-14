import { defineConfig } from '@mikro-orm/postgresql';
import { Migrator } from '@mikro-orm/migrations';
import { Tarjeta } from './tarjetas/entities/tarjeta.entity';

export default defineConfig({
  host: process.env.DBHOST || 'localhost',
  port: Number(process.env.DBPORT || 5432),
  user: process.env.DBUSER || 'postgres',
  password: process.env.DBPASSWORD || 'upt.2023',
  dbName: process.env.DBNAME || 'postgres',
  entities: [Tarjeta],
  extensions: [Migrator],
  migrations: {
    path: './dist/migrations',
    emit: 'js',
  },
  driverOptions: process.env.DBSSL
    ? { connection: { ssl: { rejectUnauthorized: false } } }
    : {},
});
