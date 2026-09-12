# Análisis de rotación de personal (SQL)

Ejercicio de análisis de datos con SQL sobre un dataset sintético de RRHH (850 empleados, 7 departamentos, 5 años de histórico), como parte de mi portafolio de transición hacia analista de datos / procesos.

## Contenido

- `rotacion-personal-consultas.sql` — 5 consultas SQL comentadas, de dificultad progresiva
- `rotacion-personal-dataset.csv` — dataset generado con distribuciones estadísticas realistas (sin datos reales de ninguna empresa)

## Las 5 consultas

1. **Tasa de rotación por departamento** — agregación con `GROUP BY` y `CASE WHEN`
2. **Antigüedad media antes de la baja** — cálculo de fechas con `julianday()`
3. **Empleados por debajo de la media salarial de su puesto** — función de ventana `AVG() OVER (PARTITION BY...)`
4. **Ranking de departamentos por rotación** — `CTE` + `RANK()`
5. **Evolución trimestral de bajas** — `CTE` + `LAG()` para comparar periodos consecutivos

## Hallazgos principales

- Atención al Cliente (28,5%) y Ventas (23,5%) triplican la rotación de Tecnología (7,6%) y RRHH (4,4%)
- En RRHH y Marketing, las pocas bajas que hay ocurren muy pronto (3-8 meses) — apunta a un problema de onboarding más que de clima a largo plazo
- Varios de los mayores desajustes salariales internos (por debajo de la media de su puesto) están en Tecnología, un departamento con baja rotación hoy pero que conviene vigilar

## Stack

SQL (SQLite), con sintaxis directamente adaptable a PostgreSQL / SQL Server.

---
Proyecto personal con datos sintéticos, sin vínculo con ninguna empresa real.
