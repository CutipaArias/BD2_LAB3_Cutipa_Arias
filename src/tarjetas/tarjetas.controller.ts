import {
  Body,
  Controller,
  Delete,
  Get,
  HttpException,
  InternalServerErrorException,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { TarjetasService } from './tarjetas.service';
import { CreateTarjetaDto } from './dto/create-tarjeta.dto';
import { UpdateTarjetaDto } from './dto/update-tarjeta.dto';
import { LoggerService } from '../logger/logger.service';

@Controller('tarjetas')
export class TarjetasController {
  private readonly context = 'TarjetasController';

  constructor(
    private readonly tarjetasService: TarjetasService,
    private readonly logger: LoggerService,
  ) {}

  private handleError(error: unknown, action: string): never {
    const err = error as Error;
    this.logger.error(
      `Error en ${action}: ${err.message}`,
      err.stack ?? '',
      this.context,
    );
    if (error instanceof HttpException) {
      throw error;
    }
    throw new InternalServerErrorException(err.message);
  }

  @Post()
  async create(@Body() createTarjetaDto: CreateTarjetaDto) {
    this.logger.log('This trigger a create request.', this.context);
    try {
      return await this.tarjetasService.create(createTarjetaDto);
    } catch (error) {
      this.handleError(error, 'create');
    }
  }

  @Get()
  async findAll() {
    this.logger.log('This trigger a findAll request.', this.context);
    try {
      return await this.tarjetasService.findAll();
    } catch (error) {
      this.handleError(error, 'findAll');
    }
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    this.logger.log('This trigger a findOne request.', this.context);
    try {
      return await this.tarjetasService.findOne(+id);
    } catch (error) {
      this.handleError(error, 'findOne');
    }
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateTarjetaDto: UpdateTarjetaDto) {
    this.logger.log('This trigger a update request.', this.context);
    try {
      return await this.tarjetasService.update(+id, updateTarjetaDto);
    } catch (error) {
      this.handleError(error, 'update');
    }
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    this.logger.log('This trigger a delete request.', this.context);
    try {
      return await this.tarjetasService.remove(+id);
    } catch (error) {
      this.handleError(error, 'remove');
    }
  }
}
