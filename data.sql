/* =====================================================================
   data.sql – DATOS DE PRUEBA (DML)
   Proyecto: Sistema de gestión de un gimnasio
   Motor: PostgreSQL 17

   Carga datos coherentes entre sí. Ejecutar después de schema.sql,
   que deja las tablas vacías y los SERIAL arrancando en 1.
   Los INSERT siguen el orden de creación de las tablas, para que cada
   clave foránea apunte a un registro que ya existe.
   ===================================================================== */


-- ---------------------------------------------------------------------
-- planes (id_plan 1 a 5)
-- ---------------------------------------------------------------------
INSERT INTO planes (nombre, precio_mensual, clases_por_semana) VALUES
    ('Básico',      25000.00, 2),   -- id 1
    ('Intermedio',  32000.00, 3),   -- id 2
    ('Full',        40000.00, 5),   -- id 3
    ('Estudiante',  20000.00, 3),   -- id 4
    ('Libre',       48000.00, 7);   -- id 5


-- ---------------------------------------------------------------------
-- clases (id_clase 1 a 7)
-- Boxeo (id 7) es una clase nueva que todavía no tiene inscriptos:
-- sirve para probar los casos de "registros sin asociaciones".
-- ---------------------------------------------------------------------
INSERT INTO clases (nombre, instructor, dia_semana, hora_inicio, cupo_maximo) VALUES
    ('Funcional',  'Martín Gómez',    'Lunes',     '08:00', 20),  -- id 1
    ('Yoga',       'Lucía Fernández', 'Martes',    '18:30', 15),  -- id 2
    ('Spinning',   'Diego Romero',    'Miércoles', '19:00', 25),  -- id 3
    ('Pilates',    'Carla Ruiz',      'Jueves',    '10:00', 12),  -- id 4
    ('Crossfit',   'Martín Gómez',    'Viernes',   '20:00', 18),  -- id 5
    ('Zumba',      'Sofía Herrera',   'Sábado',    '11:00', 30),  -- id 6
    ('Boxeo',      'Diego Romero',    'Martes',    '20:00', 16);  -- id 7 (sin inscriptos)


-- ---------------------------------------------------------------------
-- socios (id_socio 1 a 6)
-- Cada id_plan existe en planes.
-- ---------------------------------------------------------------------
INSERT INTO socios (nombre, apellido, email, telefono, fecha_nacimiento, fecha_alta, id_plan) VALUES
    ('Valentina', 'López',    'valentina.lopez@mail.com', '221-555-0101', '1995-04-12', '2026-01-15', 3),  -- id 1, Full
    ('Tomás',     'Martínez', 'tomas.martinez@mail.com',  '221-555-0102', '2001-09-03', '2026-02-01', 4),  -- id 2, Estudiante
    ('Camila',    'García',   'camila.garcia@mail.com',   '221-555-0103', '1988-12-20', '2026-03-10', 1),  -- id 3, Básico
    ('Federico',  'Sánchez',  'fede.sanchez@mail.com',    NULL,           '1992-06-30', '2026-05-22', 5),  -- id 4, Libre (sin teléfono)
    ('Julieta',   'Pérez',    'julieta.perez@mail.com',   '221-555-0105', '1999-02-14', '2026-08-05', 2),  -- id 5, Intermedio
    ('Nicolás',   'Díaz',     'nico.diaz@mail.com',       '221-555-0106', '2003-11-08', '2026-10-01', 4);  -- id 6, Estudiante


-- ---------------------------------------------------------------------
-- inscripciones
-- Cada id_socio e id_clase existe, sin repetir combinaciones.
-- ---------------------------------------------------------------------
INSERT INTO inscripciones (id_socio, id_clase, fecha_inscripcion) VALUES
    (1, 1, '2026-01-16 09:30:00-03'),  -- Valentina → Funcional
    (1, 3, '2026-01-16 09:35:00-03'),  -- Valentina → Spinning
    (1, 5, '2026-02-02 18:10:00-03'),  -- Valentina → Crossfit
    (2, 2, '2026-02-03 12:00:00-03'),  -- Tomás → Yoga
    (2, 6, '2026-02-03 12:05:00-03'),  -- Tomás → Zumba
    (3, 4, '2026-03-11 08:45:00-03'),  -- Camila → Pilates
    (4, 1, '2026-05-23 07:50:00-03'),  -- Federico → Funcional
    (4, 5, '2026-05-23 07:55:00-03'),  -- Federico → Crossfit
    (5, 2, '2026-08-06 17:20:00-03'),  -- Julieta → Yoga
    (6, 3, '2026-10-02 20:15:00-03');  -- Nicolás → Spinning
