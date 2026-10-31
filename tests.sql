/* =====================================================================
   tests.sql – PRUEBAS DE RESTRICCIONES (opcional)
   Proyecto: Sistema de gestión de un gimnasio
   Motor: PostgreSQL 17

   Cada sentencia de este archivo DEBE FALLAR: intenta guardar un dato
   inválido y la base lo rechaza. Es la evidencia de que las
   restricciones de schema.sql realmente se aplican.
   Ningún dato se guarda, así que no modifica la base.

   Cómo ejecutarlo:
     - psql:    psql -d gimnasio_db -f tests.sql
                (muestra un ERROR por cada prueba y sigue con la siguiente)
     - pgAdmin: seleccionar UNA sentencia por vez y ejecutarla, porque
                pgAdmin frena el script en el primer error.
   ===================================================================== */


-- Prueba 1 – CHECK: el email debe contener '@'
-- Error esperado: violates check constraint "chk_socios_email"
INSERT INTO socios (nombre, apellido, email, fecha_nacimiento, id_plan)
VALUES ('Prueba', 'Error', 'mailsinarroba.com', '2000-01-01', 1);

-- Prueba 2 – FOREIGN KEY: el plan debe existir
-- Error esperado: violates foreign key constraint "fk_socios_plan"
INSERT INTO socios (nombre, apellido, email, fecha_nacimiento, id_plan)
VALUES ('Prueba', 'Error', 'prueba@mail.com', '2000-01-01', 99);

-- Prueba 3 – CHECK: el precio debe ser mayor a 0
-- Error esperado: violates check constraint "chk_planes_precio_positivo"
INSERT INTO planes (nombre, precio_mensual, clases_por_semana)
VALUES ('Gratis', 0, 1);

-- Prueba 4 – UNIQUE: un socio no se anota dos veces a la misma clase
-- Error esperado: violates unique constraint "uq_inscripciones_socio_clase"
INSERT INTO inscripciones (id_socio, id_clase)
VALUES (1, 1);

-- Prueba 5 – CHECK: el día debe ser de lunes a sábado
-- Error esperado: violates check constraint "chk_clases_dia"
INSERT INTO clases (nombre, instructor, dia_semana, hora_inicio, cupo_maximo)
VALUES ('Running', 'Martín Gómez', 'Domingo', '09:00', 20);
