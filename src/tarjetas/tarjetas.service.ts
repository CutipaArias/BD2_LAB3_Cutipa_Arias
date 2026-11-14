import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { EntityManager } from '@mikro-orm/postgresql';
import { Tarjeta } from './entities/tarjeta.entity';
import { CreateTarjetaDto } from './dto/create-tarjeta.dto';
import { UpdateTarjetaDto } from './dto/update-tarjeta.dto';

@Injectable()
export class TarjetasService {
  constructor(private readonly em: EntityManager) {}

  async create(createTarjetaDto: CreateTarjetaDto) {
    const tarjeta = this.em.create(Tarjeta, createTarjetaDto);
    await this.em.persistAndFlush(tarjeta);
    return tarjeta;
  }

  async findAll() {
    return this.em.find(Tarjeta, {});
  }

  async findOne(id: number) {
    if (Number.isNaN(id)) {
      throw new BadRequestException('El id debe ser numerico');
    }
    const tarjeta = await this.em.findOne(Tarjeta, { id });
    if (!tarjeta) {
      throw new NotFoundException(`Tarjeta ${id} no encontrada`);
    }
    return tarjeta;
  }

  async update(id: number, updateTarjetaDto: UpdateTarjetaDto) {
    const tarjeta = await this.findOne(id);
    this.em.assign(tarjeta, updateTarjetaDto);
    await this.em.flush();
    return tarjeta;
  }

  async remove(id: number) {
    const tarjeta = await this.findOne(id);
    await this.em.removeAndFlush(tarjeta);
    return { deleted: true, id };
  }
}
