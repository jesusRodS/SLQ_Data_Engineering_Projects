 

SELECT job_id::VARCHAR
FROM job_postings_fact
LIMIT 5;



CREATE DATABASE jobs_mart;

USE jobs_mart;

SELECT *
FROM information_schema.schemata; 

CREATE SCHEMA jobs_mart.staging;

DROP SCHEMA staging;
DESCRIBE staging.preferred_roles;

CREATE TABLE staging.preferred_roles(
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR 
); 

SHOW TABLES;

SELECT *
FROM information_schema.tables 
WHERE table_catalog = 'jobs_mart';

DROP TABLE staging.preferred_roles;



INSERT INTO staging.preferred_roles(role_id, role_name)
VALUES
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer').
    (3, 'Software Engineer');


SELECT 
    *
FROM staging.preferred_roles;

ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

ALTER TABLE staging.preferred_roles
DROP COLUMN preferred_role;

UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE role_id = 3; 

ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

SELECT 
    *
FROM staging.priority_roles;

ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

SELECT *
FROM staging.job_postings_flat AS jpf
JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name;
