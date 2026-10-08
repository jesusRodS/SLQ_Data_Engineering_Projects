--- PASO 7: Mart - Crear company prospecting Mart

DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;


-- 1. Company dimension
CREATE TABLE company_mart.dim_company(
    company_id   INTEGER PRIMARY KEY,
    company_name VARCHAR
);

INSERT INTO company_mart.dim_company(
    company_id,
    company_name
)
SELECT 
    company_id,
    name AS company_name
FROM company_dim;

-- 2. Job title short dimension (distinct job_title_short values with IDs)
CREATE TABLE company_mart.dim_job_title_short(
    job_title_short_id INTEGER PRIMARY KEY,
    job_title_short VARCHAR
);

INSERT INTO company_mart.dim_job_title_short(
    job_title_short_id,
    job_title_short
)
WITH distinct_titles AS (
    SELECT DISTINCT
        job_title_short
    FROM job_postings_fact
    WHERE job_title_short IS NOT NULL
),
numbered_titles AS (
    SELECT
        t1.job_title_short,
        COUNT(t2.job_title_short) + 1 AS job_title_short_id
    FROM distinct_titles t1
    LEFT JOIN distinct_titles t2 
        ON t1.job_title_short < t2.job_title_short
    group BY t1.job_title_short
)
SELECT
    job_title_short_id,
    job_title_short
FROM numbered_titles
ORDER BY job_title_short;


-- 2b. Job title dimension (distinct job_title values with IDs)


CREATE TABLE company_mart.dim_job_title(
    job_title_id INTEGER PRIMARY KEY,
    job_title VARCHAR
);

INSERT INTO company_mart.dim_job_title(
    job_title_id,
    job_title
)
WITH distinct_titles AS (
    SELECT DISTINCT
        job_title
    FROM job_postings_fact
    WHERE job_title IS NOT NULL
),numbered_titles AS (
    SELECT
        t1.job_title,
        COUNT(t2.job_title) + 1 AS job_title_id
    FROM distinct_titles t1
    LEFT JOIN distinct_titles t2 
        ON t1.job_title < t2.job_title
    group BY t1.job_title
)
SELECT 
    job_title_id,
    job_title
FROM numbered_titles
ORDER BY job_title;


-- 3. Location dimension (unique location/country combinations)

CREATE TABLE company_mart.dim_location(
    location_id INTEGER PRIMARY KEY,
    job_country VARCHAR,
    job_location VARCHAR
);

INSERT INTO company_mart.dim_location(
    location_id,
    job_country,
    job_location
)
WITH distinct_locations AS (
    SELECT DISTINCT
        job_country,
        job_location
    FROM job_postings_fact
    WHERE job_country IS NOT NULL AND job_location IS NOT NULL
),numbered_locations AS (
    SELECT
        t1.job_country,
        t1.job_location,
        COUNT(t2.job_country) + 1 AS location_id
    FROM distinct_locations t1
    LEFT JOIN distinct_locations t2 
        ON (t1.job_country < t2.job_country) 
        OR (t1.job_country = t2.job_country AND t1.job_location < t2.job_location)
    group BY t1.job_country, t1.job_location
)
SELECT 
    location_id,
    job_country,
    job_location
FROM numbered_locations
ORDER BY job_country, job_location;


-- 4. Month-level date dimension

CREATE TABLE company_mart.dim_date_month(
    month_start_date DATE PRIMARY KEY,  
    year INTEGER,
    month INTEGER
);

INSERT INTO company_mart.dim_date_month(
    month_start_date,
    year,
    month
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date)::DATE AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM job_postings_fact
WHERE job_posted_date IS NOT NULL;


--- 5. Bridge Table (muchos a muchos) Company To Location, cuántas compañias contratan en que locaciones 

CREATE TABLE company_mart.bridge_company_location(
    company_id INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location(
    company_id,
    location_id
)
SELECT DISTINCT
    jpf.company_id,
    loc.location_id
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_location AS loc
    ON jpf.job_country = loc.job_country AND jpf.job_location = loc.job_location
WHERE jpf.company_id IS NOT NULL;


--- 6. Bridge Table (muchos a muchos) Job title Short to job title, Variantes de job title por cada job title short

CREATE TABLE company_mart.bridge_job_title(
    job_title_short_id INTEGER,
    job_title_id INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);


INSERT INTO company_mart.bridge_job_title(
    job_title_short_id,
    job_title_id
)
SELECT DISTINCT
    djs.job_title_short_id,
    djt.job_title_id
FROM job_postings_fact AS jpf
INNER JOIN company_mart.dim_job_title_short AS djs
    ON jpf.job_title_short = djs.job_title_short
INNER JOIN company_mart.dim_job_title AS djt
    ON jpf.job_title = djt.job_title
WHERE jpf.job_title_short IS NOT NULL 
    AND jpf.job_title IS NOT NULL;

----Crear Fact Table: fact_company_hiring_monthly

CREATE TABLE company_mart.fact_company_hiring_monthly(
    company_id INTEGER,
    job_title_short_id INTEGER,
    job_country VARCHAR,
    month_start_date DATE,
    postings_count INTEGER,
    median_salary_year DOUBLE,
    min_salary_year DOUBLE,
    max_salary_year DOUBLE,
    remote_share DOUBLE,
    health_insurance_share INTEGER,
    no_degree_mention_share INTEGER,
    PRIMARY KEY (company_id, job_title_short_id, job_country,month_start_date),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly(
    company_id,
    job_title_short_id,
    job_country,
    month_start_date,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH job_postings_prepared AS (
    SELECT 
        jpf.company_id,
        djs.job_title_short_id,
        jpf.job_country,
        DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
        jpf.salary_year_avg,
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1.0 ELSE 0.0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1.0 ELSE 0.0  END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1.0 ELSE 0.0 END AS no_degree_required
    FROM job_postings_fact AS jpf
    INNER JOIN company_mart.dim_job_title_short AS djs
        ON jpf.job_title_short = djs.job_title_short
    WHERE jpf.company_id IS NOT NULL 
      AND jpf.job_posted_date IS NOT NULL
      AND jpf.job_country IS NOT NULL 
)
SELECT
    company_id,
    job_title_short_id,
    job_country,
    month_start_date,
    COUNT(*) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    AVG(is_remote) AS remote_share,
    AVG(has_health_insurance) AS health_insurance_share,
    AVG(no_degree_required) AS no_degree_mention_share
FROM job_postings_prepared
GROUP BY 
    company_id,
    job_title_short_id,
    job_country,
    month_start_date;

--- Verificacion de datos

SELECT 'Company Dimension' AS table_name, COUNT(*) as record_count FROM company_mart.dim_company
UNION ALL
SELECT 'Job Title Short Dimension', COUNT(*) FROM company_mart.dim_job_title_short
UNION ALL
SELECT 'Job Title Dimension', COUNT(*) FROM company_mart.dim_job_title
UNION ALL
SELECT 'Location Dimension', COUNT(*) FROM company_mart.dim_location
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM company_mart.dim_date_month
UNION ALL
SELECT 'Bridge Company Location', COUNT(*) FROM company_mart.bridge_company_location
UNION ALL
SELECT 'Bridge Job Title', COUNT(*) FROM company_mart.bridge_job_title
UNION ALL
SELECT 'Fact Company Hiring Monthly', COUNT(*) FROM company_mart.fact_company_hiring_monthly;


---Muestra de datos

SELECT '=== Company Dimension Sample ===' AS info;  
SELECT *  FROM company_mart.dim_company LIMIT 5;

SELECT '=== Job Title Short Dimension Sample ===' AS info;
SELECT *  FROM company_mart.dim_job_title_short LIMIT 10;

SELECT '=== Job Title Dimension Sample ===' AS info;  
SELECT *  FROM company_mart.dim_job_title LIMIT 10;

SELECT '=== Location Dimension Sample ===' AS info;
SELECT *  FROM company_mart.dim_location LIMIT 10;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT *  FROM company_mart.dim_date_month ORDER BY month_start_date DESC LIMIT 10;

SELECT '=== Bridge Company Location Sample ===' AS info;
SELECT
    bc1.company_id,
    dc.company_name,
    bc1.location_id,    
    dl.job_country,
    dl.job_location
FROM company_mart.bridge_company_location bc1
JOIN company_mart.dim_company dc ON bc1.company_id = dc.company_id
JOIN company_mart.dim_location dl ON bc1.location_id = dl.location_id
LIMIT 10;

SELECT '=== Bridge Job Title Sample ===' AS info; 
SELECT
    bjt.job_title_short_id,
    djs.job_title_short,
    bjt.job_title_id,
    djt.job_title
FROM company_mart.bridge_job_title bjt
JOIN company_mart.dim_job_title_short djs ON bjt.job_title_short_id = djs.job_title_short_id
JOIN company_mart.dim_job_title djt ON bjt.job_title_id = djt.job_title_id
WHERE djs.job_title_short = 'Data Engineer'
LIMIT 10;

SELECT '=== Fact Company Hiring Monthly Sample ===' AS info;
SELECT 
    fchm.company_id,
    dc.company_name,
    djs.job_title_short,
    fchm.job_country,
    fchm.month_start_date,
    fchm.postings_count,
    fchm.median_salary_year,
FROM company_mart.fact_company_hiring_monthly fchm
JOIN company_mart.dim_company dc ON fchm.company_id = dc.company_id
JOIN company_mart.dim_job_title_short djs ON fchm.job_title_short_id = djs.job_title_short_id
ORDER BY fchm.postings_count DESC, fchm.median_salary_year DESC
LIMIT 10;