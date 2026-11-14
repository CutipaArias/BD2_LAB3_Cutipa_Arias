CREATE TABLE IF NOT EXISTS tarjeta (
  id SERIAL PRIMARY KEY,
  numero VARCHAR(255) NOT NULL,
  titular VARCHAR(255) NOT NULL,
  vencimiento VARCHAR(255) NOT NULL,
  tipo VARCHAR(255) NOT NULL
);

INSERT INTO tarjeta (numero, titular, vencimiento, tipo)
SELECT '4111111111111111', 'Juan Perez', '12/28', 'VISA'
WHERE NOT EXISTS (SELECT 1 FROM tarjeta WHERE numero = '4111111111111111');

INSERT INTO tarjeta (numero, titular, vencimiento, tipo)
SELECT '5500000000000004', 'Maria Lopez', '06/27', 'MASTERCARD'
WHERE NOT EXISTS (SELECT 1 FROM tarjeta WHERE numero = '5500000000000004');
