--SUBQUERY
SELECT * 
FROM (
    SELECT * 
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL 
) AS valid_salaries
LIMIT 10;

--1. USE in SELECT statement

SELECT 
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
    ) AS market_median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL 
LIMIT 10;



--2. USE in FROM statement

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS market_median_salary
FROM (
    SELECT 
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs 
GROUP BY job_title_short 
LIMIT 10;



--3. USE in HAVING statement

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS market_median_salary
FROM (
    SELECT 
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs 
GROUP BY job_title_short
HAVING MEDIAN(salary_year_avg) > (
    SELECT MEDIAN(salary_year_avg)
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
)
LIMIT 10;


--CTE

WITH valid_salaries AS (
    SELECT * 
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL 
)

SELECT *
FROM valid_salaries;


WITH title_median AS(
SELECT 
    job_title_short,
    job_work_from_home, 
    MEDIAN(salary_year_avg)::INT AS median_salary 
FROM job_postings_fact
WHERE job_country = 'United States'
GROUP BY
    job_title_short,
    job_work_from_home
)

SELECT 
    r.job_title_short,
    r.median_salary AS remote_median_salary,
    o.median_salary AS onsite_median_salary,
    (r.median_salary - o.median_salary) AS remote_premium
FROM title_median AS r 
INNER JOIN title_median AS o
    ON r.job_title_short = o.job_title_short
WHERE r.job_work_from_home = TRUE
    AND o.job_work_from_home = FALSE
ORDER BY remote_premium DESC;



---Final EXAMPLE, WHERE EXISTS, WHERE NOT EXISTS

SELECT *
FROM job_postings_fact
ORDER BY job_id 
LIMIT 10; 


SELECT *
FROM skills_job_dim
ORDER BY job_id 
LIMIT 40; 

SELECT *
FROM job_postings_fact AS tgt
WHERE EXISTS(
    SELECT 1
    FROM skills_job_dim AS src
    WHERE tgt.job_id = src.job_id   
)
ORDER BY job_id; 