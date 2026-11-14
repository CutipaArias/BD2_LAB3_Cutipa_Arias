import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateTarjetaDto {
  @ApiProperty({ example: '4111111111111111' })
  @IsString()
  @IsNotEmpty()
  numero: string;

  @ApiProperty({ example: 'Juan Perez' })
  @IsString()
  @IsNotEmpty()
  titular: string;

  @ApiProperty({ example: '12/28' })
  @IsString()
  @IsNotEmpty()
  vencimiento: string;

  @ApiProperty({ example: 'VISA' })
  @IsString()
  @IsNotEmpty()
  tipo: string;
}
