---duckdb dw_marts.duckdb -c ".read build_marts.sql" 


---Paso 1: DW - Crear tablas, schema Star
.read 01_create_tables_dw.sql

---Paso 2: DW - Cargar datos en las tablas de CSV

.read 02_load_schema_dw.sql

---Paso 3: Mart - Crear flat mart

.read 03_create_flat_mart.sql

---Paso 4: Create Skills demand mart

.read 04_create_skills_mart.sql


--- Paso 5: Mart - Crear priority Mart

.read 05_create_priority_mart.sql

--- Paso 6: Mart - Actualizar priority Mart

.read 06_update_priority_mart.sql