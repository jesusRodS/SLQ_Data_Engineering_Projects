CREATE TEMP TABLE jobs_2023 AS 
SELECT * EXCLUDE(job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2023; 

SELECT * 
FROM jobs_2023;


CREATE TEMP TABLE jobs_2024 AS 
SELECT * EXCLUDE(job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date) = 2024;


SELECT * 
FROM jobs_2024;


----Cuáles posteo únicos de trabajo aparecieron en 2023 o 2024?


SELECT
    'jobs_2023' AS table_name,
    COUNT(*) 
FROM jobs_2023
UNION
SELECT
    'jobs_2024' AS table_name, 
    COUNT(*) 
FROM jobs_2024;

SELECT * 
FROM jobs_2023
UNION
SELECT * 
FROM jobs_2024;


------ Cuáles apareciero en los 2 años, contando duplicados?

SELECT * 
FROM jobs_2023
UNION ALL
SELECT * 
FROM jobs_2024;


------- Cuáles aparecieron en 2023 pero no en 2024

SELECT * 
FROM jobs_2023
EXCEPT
SELECT * 
FROM jobs_2024;


------¿Qué ofertas de empleo de 2023 quedan tras restar, una a una, las ofertas coincidentes de 2024?

SELECT * 
FROM jobs_2023
EXCEPT ALL
SELECT * 
FROM jobs_2024;

----Qué trabajos aparecieron en ambos años?

SELECT * 
FROM jobs_2023
INTERSECT 
SELECT * 
FROM jobs_2024;

-----Qué trabajos aparecieron en ambos años manteniendo los duplicados?
SELECT * 
FROM jobs_2023
INTERSECT ALL
SELECT * 
FROM jobs_2024;