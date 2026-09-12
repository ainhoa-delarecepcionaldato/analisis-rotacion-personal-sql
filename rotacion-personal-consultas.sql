-- =====================================================================
-- Análisis de rotación de personal (HR Analytics)
-- Base de datos: hr_analytics.db · Tabla: employees
-- =====================================================================
-- Esquema:
--   employee_id        INTEGER
--   full_name          TEXT
--   department         TEXT
--   job_title          TEXT
--   hire_date          TEXT (YYYY-MM-DD)
--   termination_date   TEXT (YYYY-MM-DD) — NULL si sigue en la empresa
--   salary             INTEGER (bruto anual, EUR)
--   age                INTEGER
--   gender             TEXT ('F' / 'M')
--   performance_score  REAL (1.0 – 5.0)
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. Tasa de rotación por departamento
-- ---------------------------------------------------------------------
-- Objetivo: saber en qué departamentos se pierde más gente, en términos
-- relativos (no solo en número absoluto de bajas).
SELECT
    department,
    COUNT(*) AS total_empleados,
    SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END) AS bajas,
    ROUND(
        100.0 * SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END)
        / COUNT(*), 1
    ) AS tasa_rotacion_pct
FROM employees
GROUP BY department
ORDER BY tasa_rotacion_pct DESC;


-- ---------------------------------------------------------------------
-- 2. Antigüedad media antes de la baja, por departamento
-- ---------------------------------------------------------------------
-- Objetivo: no basta con saber CUÁNTOS se van, sino CUÁNDO se van.
-- Una rotación alta con bajas muy tempranas apunta a un problema de
-- onboarding; una rotación alta con antigüedad larga apunta a otra causa.
SELECT
    department,
    COUNT(*) AS bajas,
    ROUND(AVG(
        (julianday(termination_date) - julianday(hire_date)) / 30.44
    ), 1) AS antiguedad_media_meses
FROM employees
WHERE termination_date IS NOT NULL
GROUP BY department
ORDER BY antiguedad_media_meses ASC;


-- ---------------------------------------------------------------------
-- 3. Empleados por debajo de la media salarial de su propio puesto
-- ---------------------------------------------------------------------
-- Objetivo: detectar posibles casos de desajuste salarial interno,
-- comparando a cada persona contra la media de SU MISMO puesto
-- (función de ventana AVG() OVER PARTITION BY), no contra la media
-- general de la empresa.
SELECT
    full_name,
    department,
    job_title,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY job_title), 0) AS media_del_puesto,
    ROUND(salary - AVG(salary) OVER (PARTITION BY job_title), 0) AS diferencia
FROM employees
WHERE termination_date IS NULL
ORDER BY diferencia ASC
LIMIT 10;


-- ---------------------------------------------------------------------
-- 4. Ranking de departamentos por rotación (RANK())
-- ---------------------------------------------------------------------
-- Objetivo: la misma tasa de rotación de la consulta 1, pero con un
-- ranking explícito (RANK()), útil para destacar automáticamente los
-- 2-3 departamentos prioritarios en un informe o dashboard.
WITH rotacion AS (
    SELECT
        department,
        COUNT(*) AS total_empleados,
        SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END) AS bajas,
        100.0 * SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END)
            / COUNT(*) AS tasa_rotacion_pct
    FROM employees
    GROUP BY department
)
SELECT
    department,
    total_empleados,
    bajas,
    ROUND(tasa_rotacion_pct, 1) AS tasa_rotacion_pct,
    RANK() OVER (ORDER BY tasa_rotacion_pct DESC) AS ranking_prioridad
FROM rotacion
ORDER BY ranking_prioridad;


-- ---------------------------------------------------------------------
-- 5. Evolución trimestral de bajas, con variación respecto al trimestre
--    anterior (LAG())
-- ---------------------------------------------------------------------
-- Objetivo: ver si la rotación se está agravando o mejorando con el
-- tiempo, no solo un número acumulado sin contexto temporal.
WITH bajas_trimestre AS (
    SELECT
        strftime('%Y', termination_date) || '-T' ||
            ((CAST(strftime('%m', termination_date) AS INTEGER) - 1) / 3 + 1) AS trimestre,
        COUNT(*) AS bajas
    FROM employees
    WHERE termination_date IS NOT NULL
    GROUP BY trimestre
)
SELECT
    trimestre,
    bajas,
    LAG(bajas) OVER (ORDER BY trimestre) AS bajas_trimestre_anterior,
    bajas - LAG(bajas) OVER (ORDER BY trimestre) AS variacion
FROM bajas_trimestre
ORDER BY trimestre;
