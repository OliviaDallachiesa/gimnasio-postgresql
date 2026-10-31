/* =====================================================================
   schema.sql – ESTRUCTURA (DDL)
   Proyecto: Sistema de gestión de un gimnasio
   Motor: PostgreSQL 17

   Crea las 4 tablas del modelo con sus claves primarias, claves
   foráneas y restricciones. Ejecutar sobre una base vacía, antes de
   data.sql y queries.sql.

   Relaciones:
     - planes (1) ──< (N) socios          → un plan tiene muchos socios
     - socios (1) ──< (N) inscripciones   → un socio se anota a muchas clases
     - clases (1) ──< (N) inscripciones   → una clase tiene muchos inscriptos
   ===================================================================== */


/* ---------------------------------------------------------------------
   1. LIMPIEZA
   Borra las tablas si ya existen, para que el script se pueda ejecutar
   varias veces. Se borran en orden inverso a su creación: primero las
   que tienen claves foráneas.
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS inscripciones;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS clases;
DROP TABLE IF EXISTS planes;


/* ---------------------------------------------------------------------
   2. TABLAS SIN DEPENDENCIAS
   Se crean primero porque no referencian a ninguna otra tabla.
   --------------------------------------------------------------------- */

-- Tabla: planes
-- Tipos de membresía que ofrece el gimnasio.
CREATE TABLE planes (
    id_plan            SERIAL          PRIMARY KEY,
    nombre             VARCHAR(50)     NOT NULL UNIQUE,
    precio_mensual     DECIMAL(10, 2)  NOT NULL,
    clases_por_semana  INTEGER         NOT NULL,

    CONSTRAINT chk_planes_precio_positivo CHECK (precio_mensual > 0),
    CONSTRAINT chk_planes_clases_semana   CHECK (clases_por_semana BETWEEN 1 AND 7)
);

-- Tabla: clases
-- Clases grupales que dicta el gimnasio.
CREATE TABLE clases (
    id_clase      SERIAL        PRIMARY KEY,
    nombre        VARCHAR(50)   NOT NULL,
    instructor    VARCHAR(100)  NOT NULL,
    dia_semana    VARCHAR(10)   NOT NULL,
    hora_inicio   TIME          NOT NULL,
    cupo_maximo   INTEGER       NOT NULL,

    CONSTRAINT chk_clases_dia CHECK (
        dia_semana IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado')
    ),
    CONSTRAINT chk_clases_cupo_positivo CHECK (cupo_maximo > 0)
);


/* ---------------------------------------------------------------------
   3. TABLAS CON CLAVES FORÁNEAS
   Se crean después de las tablas a las que referencian.
   Las FK son INTEGER, el mismo tipo que el SERIAL de las PK.
   --------------------------------------------------------------------- */

-- Tabla: socios
-- Personas inscriptas en el gimnasio. Cada socio tiene un plan.
-- FK: id_plan → planes(id_plan)
CREATE TABLE socios (
    id_socio          SERIAL        PRIMARY KEY,
    nombre            VARCHAR(50)   NOT NULL,
    apellido          VARCHAR(50)   NOT NULL,
    email             VARCHAR(100)  NOT NULL UNIQUE,
    telefono          VARCHAR(20),
    fecha_nacimiento  DATE          NOT NULL,
    fecha_alta        DATE          NOT NULL DEFAULT CURRENT_DATE,
    id_plan           INTEGER       NOT NULL,

    CONSTRAINT chk_socios_email CHECK (email LIKE '%@%'),

    CONSTRAINT fk_socios_plan
        FOREIGN KEY (id_plan) REFERENCES planes (id_plan)
);

-- Tabla: inscripciones
-- Tabla intermedia: qué socio está anotado en qué clase.
-- FK: id_socio → socios(id_socio)
-- FK: id_clase → clases(id_clase)
CREATE TABLE inscripciones (
    id_inscripcion     SERIAL                    PRIMARY KEY,
    id_socio           INTEGER                   NOT NULL,
    id_clase           INTEGER                   NOT NULL,
    fecha_inscripcion  TIMESTAMP WITH TIME ZONE  NOT NULL DEFAULT NOW(),

    -- Un socio no puede anotarse dos veces a la misma clase
    CONSTRAINT uq_inscripciones_socio_clase UNIQUE (id_socio, id_clase),

    CONSTRAINT fk_inscripciones_socio
        FOREIGN KEY (id_socio) REFERENCES socios (id_socio),
    CONSTRAINT fk_inscripciones_clase
        FOREIGN KEY (id_clase) REFERENCES clases (id_clase)
);
