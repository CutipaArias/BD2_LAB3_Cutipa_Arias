import { Entity, PrimaryKey, Property } from '@mikro-orm/core';

@Entity({ tableName: 'tarjeta' })
export class Tarjeta {
  @PrimaryKey()
  id!: number;

  @Property()
  numero!: string;

  @Property()
  titular!: string;

  @Property()
  vencimiento!: string;

  @Property()
  tipo!: string;
}
