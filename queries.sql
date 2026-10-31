/* =====================================================================
   queries.sql – CONSULTAS (DQL)
   Proyecto: Sistema de gestión de un gimnasio
   Motor: PostgreSQL 17

   Ejecutar después de schema.sql y data.sql.

   Tablas: planes, clases, socios, inscripciones
   Relaciones:
     - socios.id_plan        → planes.id_plan
     - inscripciones.id_socio → socios.id_socio
     - inscripciones.id_clase → clases.id_clase

   Este archivo contiene solo consultas SELECT.
   ===================================================================== */


-- =====================================================================
-- CONSULTA 1 – INNER JOIN
-- Problema: listar cada socio con el plan que tiene contratado y su
-- precio mensual, para que recepción controle las cuotas.
-- Une socios con planes a través de la FK socios.id_plan.
-- =====================================================================
SELECT s.nombre,
       s.apellido,
       p.nombre         AS plan,
       p.precio_mensual
FROM socios s
INNER JOIN planes p ON p.id_plan = s.id_plan
ORDER BY s.apellido;


-- =====================================================================
-- CONSULTA 2 – LEFT JOIN (registros sin asociaciones)
-- Problema: detectar las clases que no sumaron inscriptos nuevos en
-- octubre de 2026, para planificar promociones.
-- El LEFT JOIN conserva TODAS las clases; las que no tienen una
-- inscripción entre el 1 y el 31 de octubre quedan con NULL del lado
-- de inscripciones. El filtro de fechas va en el ON (no en el WHERE)
-- para no anular el efecto del LEFT JOIN.
-- Las fechas llevan la zona horaria de Argentina (-03) para que el
-- resultado no dependa de la configuración horaria del servidor.
-- =====================================================================
SELECT c.nombre AS clase,
       c.dia_semana,
       c.instructor
FROM clases c
LEFT JOIN inscripciones i
       ON i.id_clase = c.id_clase
      AND i.fecha_inscripcion >= '2026-10-01 00:00:00-03'
      AND i.fecha_inscripcion <  '2026-11-01 00:00:00-03'
WHERE i.id_inscripcion IS NULL
ORDER BY c.id_clase;


-- =====================================================================
-- CONSULTA 3 – Agregación (COUNT) + GROUP BY
-- Problema: contar cuántos socios hay inscriptos en cada clase y
-- compararlo con su cupo máximo, para medir la demanda.
-- El LEFT JOIN incluye también las clases sin inscriptos, que aparecen
-- con 0 porque COUNT(i.id_inscripcion) no cuenta los NULL.
-- =====================================================================
SELECT c.nombre                 AS clase,
       c.cupo_maximo,
       COUNT(i.id_inscripcion)  AS inscriptos
FROM clases c
LEFT JOIN inscripciones i ON i.id_clase = c.id_clase
GROUP BY c.id_clase, c.nombre, c.cupo_maximo
ORDER BY inscriptos DESC, c.nombre;


-- =====================================================================
-- CONSULTA 4 – CTE (WITH)
-- Problema: calcular la facturación mensual de cada plan y qué
-- porcentaje del total del gimnasio representa.
-- Paso 1 (CTE): cantidad de socios y facturación por plan.
-- Paso 2: sobre ese resultado, calcular el % de cada plan.
-- =====================================================================
WITH facturacion_por_plan AS (
    SELECT p.nombre              AS plan,
           COUNT(s.id_socio)     AS cantidad_socios,
           SUM(p.precio_mensual) AS facturacion_mensual
    FROM planes p
    INNER JOIN socios s ON s.id_plan = p.id_plan
    GROUP BY p.id_plan, p.nombre
)
SELECT plan,
       cantidad_socios,
       facturacion_mensual,
       ROUND(facturacion_mensual * 100.0
             / (SELECT SUM(facturacion_mensual) FROM facturacion_por_plan), 1) AS porcentaje_del_total
FROM facturacion_por_plan
ORDER BY facturacion_mensual DESC, plan;


-- =====================================================================
-- CONSULTA 5 – Top N (ORDER BY + LIMIT)
-- Problema: obtener el top 3 de socios más activos (anotados en más
-- clases) para un programa de beneficios.
-- Une las 3 tablas socios, inscripciones y planes, cuenta las clases
-- de cada socio y se queda con los 3 primeros.
-- =====================================================================
SELECT s.nombre,
       s.apellido,
       p.nombre                 AS plan,
       COUNT(i.id_inscripcion)  AS clases_inscriptas
FROM socios s
INNER JOIN inscripciones i ON i.id_socio = s.id_socio
INNER JOIN planes p        ON p.id_plan  = s.id_plan
GROUP BY s.id_socio, s.nombre, s.apellido, p.nombre
ORDER BY clases_inscriptas DESC, s.apellido
LIMIT 3;
