# Sistema de gestión de un gimnasio – Base de datos PostgreSQL 17

Proyecto final del curso de SQL de Coderhouse. Es la base de datos de un **gimnasio local**: registra los planes de membresía, los socios, las clases grupales y en qué clases está anotado cada socio. Con esa información, el gimnasio puede controlar cuotas, medir la demanda de cada clase y saber cuánto factura cada plan.

## Modelo de datos

| Tabla | Qué guarda | Clave primaria | Claves foráneas |
|---|---|---|---|
| `planes` | Tipos de membresía, precio mensual y clases por semana | `id_plan` | — |
| `clases` | Clases grupales: instructor, día, horario y cupo | `id_clase` | — |
| `socios` | Datos de cada socio y el plan que tiene | `id_socio` | `id_plan` → `planes` |
| `inscripciones` | Qué socio está anotado en qué clase y cuándo se anotó | `id_inscripcion` | `id_socio` → `socios`, `id_clase` → `clases` |

```
planes (1) ──< (N) socios (1) ──< (N) inscripciones (N) >── (1) clases
```

- Un plan tiene muchos socios.
- Un socio puede anotarse en muchas clases, y una clase tiene muchos socios. La tabla intermedia `inscripciones` resuelve esa relación de muchos a muchos.

**Restricciones principales:**

- `CHECK`: el email debe contener `@`, el precio debe ser mayor a 0, el cupo debe ser positivo y el día de la clase debe ser de lunes a sábado.
- `UNIQUE`: no se repiten emails ni nombres de plan, y un socio no puede anotarse dos veces a la misma clase.
- `FOREIGN KEY`: no puede haber socios con un plan inexistente ni inscripciones de socios o clases que no existen.

## Archivos del repositorio

| Archivo | Contenido |
|---|---|
| `schema.sql` | DDL: crea las 4 tablas con sus claves y restricciones. Empieza borrando las tablas si existen, así se puede volver a ejecutar. |
| `data.sql` | DML: datos de prueba coherentes (5 planes, 7 clases, 6 socios, 10 inscripciones). |
| `queries.sql` | DQL: 5 consultas que responden preguntas de negocio. |
| `tests.sql` | Opcional: 5 pruebas que intentan guardar datos inválidos y deben fallar, como evidencia de que las restricciones funcionan. |

## Preguntas de negocio que responde `queries.sql`

| # | Pregunta | Técnica |
|---|---|---|
| 1 | ¿Qué plan tiene cada socio y cuánto paga por mes? | `INNER JOIN` |
| 2 | ¿Qué clases no sumaron inscriptos nuevos en octubre de 2026? | `LEFT JOIN` + `IS NULL` |
| 3 | ¿Cuántos inscriptos tiene cada clase frente a su cupo, incluidas las que no tienen ninguno? | `LEFT JOIN` + `COUNT` + `GROUP BY` |
| 4 | ¿Cuánto factura cada plan por mes y qué porcentaje del total representa? | CTE (`WITH`) + subconsulta |
| 5 | ¿Quiénes son los 3 socios más activos? | `JOIN` de 3 tablas + `ORDER BY` + `LIMIT` |

## Cómo ejecutarlo

**Requisito:** PostgreSQL 17 instalado y el servicio en ejecución. Para comprobar que el servidor está activo:

```bash
pg_isready
# Respuesta esperada: localhost:5432 - accepting connections
```

### Opción 1: psql (terminal)

```bash
# 1. Clonar el repositorio
git clone <URL-del-repositorio>
cd <carpeta-del-repositorio>

# 2. Crear una base vacía
psql -U postgres -c "CREATE DATABASE gimnasio_db;"

# 3. Ejecutar los scripts en este orden
psql -U postgres -d gimnasio_db -f schema.sql
psql -U postgres -d gimnasio_db -f data.sql
psql -U postgres -d gimnasio_db -f queries.sql

# 4. (Opcional) Probar las restricciones: cada prueba debe mostrar un ERROR
psql -U postgres -d gimnasio_db -f tests.sql
```

### Opción 2: pgAdmin 4

1. Clic derecho en **Databases** → **Create** → **Database…** y crear `gimnasio_db`.
2. Seleccionar `gimnasio_db` y abrir **Tools** → **Query Tool**.
3. Abrir `schema.sql` (ícono de carpeta), ejecutar con **Execute script** (F5) y verificar en *Messages* que no haya errores.
4. Repetir con `data.sql` y después con `queries.sql`. Para ver el resultado de una consulta puntual, seleccionar su texto y ejecutar.
5. (Opcional) En `tests.sql`, seleccionar **una prueba por vez** y ejecutarla. Cada una debe dar error, porque pgAdmin frena el script en el primer error.

> El orden importa: `schema.sql` crea las tablas, `data.sql` las carga y `queries.sql` las consulta.

## Resultados esperados

| Consulta | Filas | Resultado |
|---|---|---|
| 1 | 6 | Los 6 socios con su plan y precio |
| 2 | 6 | Funcional, Yoga, Pilates, Crossfit, Zumba y Boxeo (Spinning tuvo una inscripción el 2 de octubre) |
| 3 | 7 | Las 7 clases; Boxeo aparece con 0 inscriptos |
| 4 | 5 | Facturación total de $185.000; el plan Libre es el que más aporta (25,9 %) |
| 5 | 3 | Valentina López (3 clases), Tomás Martínez (2) y Federico Sánchez (2) |

## Validación

Los scripts se probaron en una base vacía, ejecutando `schema.sql` → `data.sql` → `queries.sql` en orden y sin errores. También se verificó que:

- `schema.sql` y `data.sql` se pueden volver a ejecutar desde cero.
- No hay registros huérfanos: todas las claves foráneas apuntan a registros existentes.
- El total de la consulta 4 coincide con una suma independiente de las cuotas de cada socio ($185.000).
- La consulta 2 no cuenta inscripciones de noviembre y da el mismo resultado sin importar la zona horaria del servidor.
- Las 5 pruebas de `tests.sql` son rechazadas por la restricción correspondiente.
