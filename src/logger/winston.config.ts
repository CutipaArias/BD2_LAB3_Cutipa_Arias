import { createLogger, format, transports } from 'winston';
import 'winston-mongodb';

export const logger = createLogger({
  level: 'info',
  format: format.combine(format.timestamp(), format.json()),
  transports: [
    new transports.MongoDB({
      level: 'info',
      db:
        process.env.MONGOURL ||
        'mongodb://upt:upt.2023@localhost/logdb?authSource=admin',
      collection: 'logs',
    }),
  ],
});
