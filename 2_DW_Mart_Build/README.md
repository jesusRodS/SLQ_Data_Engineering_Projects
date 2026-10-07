# 🏗️ Construcción del almacén de datos y marts: pipeline ETL

Pipeline de ingeniería de datos de principio a fin: transforma archivos CSV sin procesar de Google Cloud Storage en un almacén de datos normalizado con esquema en estrella y, después, construye marts analíticos.

![Arquitectura del pipeline de datos](../images/1_2_Project2_Data_Pipeline.png)

---

## 🧾 Resumen ejecutivo

- ✅ **Alcance:** Se construyó un **pipeline ETL completo**, desde los CSV sin procesar hasta el almacén con esquema en estrella y los marts analíticos.
- ✅ **Modelado de datos:** Se diseñó un **esquema en estrella** con tablas de hechos, dimensiones y tablas puente para relaciones de muchos a muchos.
- ✅ **Desarrollo del ETL:** Se implementaron procesos de **extracción, transformación y carga**, con operaciones idempotentes y controles de calidad.
- ✅ **Arquitectura de los marts:** Se crearon marts **plano, de habilidades y de puestos prioritarios**, con métricas aditivas y actualizaciones incrementales.

---

## 🧩 Problema y contexto

Los datos de ofertas de empleo llegan como archivos CSV sin estructura analítica a Google Cloud Storage. Para analizarlos, es necesario responder preguntas como:

- ¿Qué habilidades tienen más demanda a lo largo del tiempo?
- ¿Cómo varían las contrataciones según la empresa y la ubicación?
- ¿Qué diferencias salariales hay entre puestos y habilidades?

**El reto:** Los equipos de datos necesitan una fuente única y confiable —un almacén de datos— para que el análisis sea coherente en toda la organización. También hacen falta marts especializados que preparen los datos para casos de uso concretos, simplifiquen las consultas y mejoren el rendimiento.

**La solución:** Un pipeline ETL que extrae los CSV del almacenamiento en la nube, organiza los datos en un almacén con esquema en estrella —separando hechos y dimensiones— y crea marts para consultas generales, análisis de demanda de habilidades y seguimiento de puestos prioritarios.

---

## 🧰 Herramientas

- 🐤 **Base de datos:** DuckDB, una base OLAP basada en archivos, con integración con GCS mediante `httpfs`.
- 🧮 **Lenguaje:** SQL; DDL para definir el esquema y DML para cargar y transformar los datos.
- 📊 **Modelo de datos:** esquema en estrella con tablas de hechos, dimensiones y tablas puente.
- 🛠️ **Entorno de desarrollo:** VS Code para editar SQL y la terminal para ejecutar DuckDB CLI.
- 🔧 **Automatización:** script SQL principal para coordinar la construcción del pipeline.
- 📦 **Control de versiones:** Git y GitHub para mantener el historial de los scripts.
- ☁️ **Almacenamiento:** Google Cloud Storage para los CSV de origen.

---

## 📂 Estructura de la carpeta

```text
2_DW_Mart_Build/
├── 01_create_tables_dw.sql        # Crea las tablas del esquema en estrella
├── 02_load_schema_dw.sql          # Extrae y carga datos desde GCS
├── 03_create_flat_mart.sql        # Construye el mart plano
├── 04_create_skills_mart.sql      # Construye el mart de demanda de habilidades
├── 05_create_priority_mart.sql    # Construye el mart de puestos prioritarios
├── 06_update_priority_mart.sql    # Actualiza el mart prioritario con MERGE
├── build_dw_marts.sql             # Script principal de construcción
├── dw_marts.duckdb                # Base de datos DuckDB generada
└── README.md                      # Este archivo
```

---

## 🏗️ Arquitectura del pipeline


![Arquitectura del pipeline de datos](../images/1_2_Project2_Data_Pipeline.png)

El pipeline transforma los CSV de ofertas de empleo de Google Cloud Storage en un almacén normalizado con esquema en estrella y, a continuación, construye marts analíticos especializados. Herramientas de BI como Excel, Power BI, Tableau y Python pueden consultar tanto el almacén como los marts.

### Almacén de datos

El almacén implementa un esquema en estrella con las tablas `company_dim`, `skills_dim`, `job_postings_fact` y `skills_job_dim`.

![Esquema del almacén de datos](../images/1_2_Data_Warehouse.png)

- **Scripts SQL:**
  - [`01_create_tables_dw.sql`](./01_create_tables_dw.sql): define las cuatro tablas principales del esquema en estrella.
  - [`02_load_schema_dw.sql`](./02_load_schema_dw.sql): extrae los CSV de GCS y los carga en las tablas del almacén.
- **Propósito:** ofrecer una fuente única y coherente para las consultas analíticas.
- **Granularidad:** una fila por oferta de empleo en la tabla de hechos `job_postings_fact`.

### Mart plano

Tabla desnormalizada que reúne las dimensiones para facilitar consultas puntuales.

![Esquema del mart plano](../images/1_2_Flat_Mart.png)

- **Script SQL:** [`03_create_flat_mart.sql`](./03_create_flat_mart.sql): crea una tabla desnormalizada con las dimensiones combinadas.
- **Propósito:** agilizar consultas exploratorias y puntuales.
- **Granularidad:** una fila por oferta de empleo, con sus dimensiones asociadas.

### Mart de habilidades

Análisis temporal de la demanda de habilidades con métricas aditivas.

![Esquema del mart de habilidades](../images/1_2_Skills_Mart.png)

- **Script SQL:** [`04_create_skills_mart.sql`](./04_create_skills_mart.sql): crea el mart temporal de demanda de habilidades.
- **Propósito:** analizar cómo cambia la demanda a lo largo del tiempo mediante métricas aditivas.
- **Granularidad:** `skill_id + month_start_date + job_title_short`.
- **Característica principal:** todas las métricas son aditivas (conteos y sumas), por lo que pueden volver a agregarse de forma segura.

### Mart de puestos prioritarios

Seguimiento de puestos prioritarios con actualizaciones incrementales mediante operaciones `MERGE`.

![Esquema del mart de puestos prioritarios](../images/1_2_Priority_Mart.png)

- **Scripts SQL:**
  - [`05_create_priority_mart.sql`](./05_create_priority_mart.sql): crea inicialmente el mart y la instantánea de ofertas prioritarias.
  - [`06_update_priority_mart.sql`](./06_update_priority_mart.sql): aplica una **actualización incremental con `MERGE`** (patrón de inserción o actualización).
- **Propósito:** hacer seguimiento de los puestos prioritarios y de sus instantáneas, con capacidad de actualización incremental.
- **Granularidad:** una fila por oferta de empleo, con su nivel de prioridad.
- **Característica principal:** `MERGE` permite insertar, actualizar o eliminar registros en una sola operación, un patrón útil en pipelines de producción.

---

## 💻 Técnicas de ingeniería de datos aplicadas

### Desarrollo del pipeline ETL

- **Extracción:** carga directa de CSV desde Google Cloud Storage mediante la extensión `httpfs` de DuckDB.
- **Transformación:** normalización de datos, conversión de tipos (`CAST`, `DATE_TRUNC`) y filtros de calidad.
- **Carga:** creación idempotente de tablas mediante patrones como `DROP TABLE IF EXISTS`.
- **Actualizaciones incrementales:** operaciones `MERGE` para insertar, actualizar o eliminar registros.
- **Orquestación:** ejecución automatizada del pipeline mediante el script principal `build_dw_marts.sql`.

### Modelado dimensional

- **Esquema en estrella:** tabla de hechos `job_postings_fact` y dimensiones como `company_dim` y `skills_dim`.
- **Tabla puente:** `skills_job_dim` resuelve relaciones de muchos a muchos.
- **Definición de granularidad:** se establece el nivel de detalle adecuado para cada tabla y mart.
- **Métricas aditivas:** conteos y sumas que pueden agregarse de nuevo en distintos niveles.



### Técnicas avanzadas de SQL

- **Operaciones DDL:** `CREATE TABLE`, `DROP TABLE` y `CREATE SCHEMA` para gestionar esquemas.
- **Operaciones DML:** `INSERT INTO ... SELECT`, con asignación explícita de columnas desde los CSV.
- **Operaciones `MERGE`:** actualizaciones incrementales con cláusulas `WHEN MATCHED`, `WHEN NOT MATCHED` y `WHEN NOT MATCHED BY SOURCE`.
- **CTE:** expresiones de tabla comunes para transformaciones complejas y conversión de indicadores booleanos.
- **Funciones de fecha:** `DATE_TRUNC('month')` y `EXTRACT(quarter)` para crear dimensiones temporales.
- **Funciones de texto:** `STRING_AGG` para concatenar y `REPLACE` para limpiar datos.
- **Lógica booleana:** conversiones con `CASE WHEN` para agregar indicadores, como trabajo remoto, seguro médico o requisito de título.

### Calidad de datos y prácticas de producción

- **Idempotencia:** los scripts se pueden ejecutar de nuevo sin generar efectos inesperados.
- **Validación de datos:** consultas de comprobación en cada etapa para verificar la integridad de los datos.
- **Seguridad de tipos:** definición explícita de tipos como `VARCHAR`, `INTEGER`, `DOUBLE`, `BOOLEAN` y `TIMESTAMP`.
- **Organización de esquemas:** separación lógica en `flat_mart`, `skills_mart` y `priority_mart`.
- **Gestión de errores:** ejecución estructurada de los scripts, con mensajes claros y seguimiento del progreso.