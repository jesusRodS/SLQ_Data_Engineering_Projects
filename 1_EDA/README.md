# 🔍 Análisis exploratorio con SQL: mercado laboral

![Resumen del proyecto de análisis exploratorio](../images/1_1_Project1_EDA.png)

Proyecto de análisis del mercado laboral para ingenieros de datos a partir de ofertas de empleo reales. Aquí se muestra cómo **escribir consultas analíticas de calidad, diseñar SQL eficiente y convertir preguntas de negocio en conclusiones basadas en datos**.

---

## 🧾 Resumen ejecutivo

- ✅ **Alcance:** Se crearon **3 consultas analíticas** para responder preguntas clave sobre el mercado laboral de ingeniería de datos.
- ✅ **Modelado de datos:** Se combinaron tablas de hechos y dimensiones mediante **uniones entre varias tablas**.
- ✅ **Análisis:** Se aplicaron **agregaciones, filtros y ordenamientos** para identificar las habilidades más demandadas, mejor pagadas y valiosas en conjunto.
- ✅ **Resultados:** Se obtuvieron conclusiones útiles sobre el peso de SQL y Python, las tendencias en la nube y los salarios.

Consultas:

1. [`01_top_demanded_skills.sql`](./01_top_demanded_skills.sql): análisis de demanda con uniones entre varias tablas.
2. [`02_top_paying_skills.sql`](./02_top_paying_skills.sql): análisis salarial mediante agregaciones.
3. [`03_optimal_skills.sql`](./03_optimal_skills.sql): consulta que combina demanda y salario para identificar habilidades convenientes.

---

## 🧩 Problema y contexto

Al analizar el mercado laboral, conviene responder preguntas como estas:

- 🎯 **Más demandadas:** *¿Qué habilidades se buscan más en ingeniería de datos?*
- 💰 **Mejor pagadas:** *¿Qué habilidades se asocian con los salarios más altos?*
- ⚖️ **Mejor equilibrio:** *¿Qué conjunto de habilidades combina mejor demanda y remuneración?*

El análisis se basa en un **almacén de datos** con un esquema en estrella, compuesto por:

![Esquema del almacén de datos](../images/1_2_Data_Warehouse.png)

- **Tabla de hechos:** `job_postings_fact`, con los detalles de cada oferta: cargo, ubicación, salario, fecha y otros datos.
- **Tablas de dimensiones:** `company_dim`, con información de las empresas, y `skills_dim`, con el catálogo de habilidades y sus tipos.
- **Tabla puente:** `skills_job_dim`, que resuelve la relación de muchos a muchos entre las ofertas y las habilidades.

Al consultar estas tablas relacionadas, se identifican patrones de demanda y salarios, así como combinaciones de habilidades convenientes para puestos de ingeniería de datos.

---

## 🧰 Herramientas

- 🐤 **Motor de consultas:** DuckDB, para consultas analíticas rápidas de tipo OLAP.
- 🧮 **Lenguaje:** SQL de estilo ANSI, con funciones analíticas.
- 📊 **Modelo de datos:** esquema en estrella con tablas de hechos, dimensiones y una tabla puente.
- 🛠️ **Entorno de desarrollo:** VS Code para editar SQL y la terminal para usar DuckDB CLI.
- 📦 **Control de versiones:** Git y GitHub para mantener el historial de los scripts SQL.

---

## 📂 Estructura de la carpeta

```text
1_EDA/
├── 01_top_demanded_skills.sql    # Análisis de las habilidades más demandadas
├── 02_top_paying_skills.sql      # Análisis de las habilidades mejor pagadas
├── 03_optimal_skills.sql         # Análisis conjunto de demanda y salario
└── README.md                     # Este archivo
```
---

## 🏗 Análisis

### Consultas

1. **[Habilidades más demandadas](./01_top_demanded_skills.sql):** identifica las 10 habilidades más solicitadas para puestos remotos de ingeniería de datos.
2. **[Habilidades mejor pagadas](./02_top_paying_skills.sql):** analiza las 25 habilidades con mejores salarios, junto con métricas de demanda.
3. **[Habilidades más convenientes](./03_optimal_skills.sql):** calcula una puntuación que combina el logaritmo natural de la demanda con el salario mediano para destacar habilidades valiosas.

### Principales conclusiones

- 🧠 **Lenguajes esenciales:** SQL y Python aparecen cada uno en unas 29.000 ofertas, por lo que son las habilidades más solicitadas.
- ☁️ **Plataformas en la nube:** AWS y Azure son importantes en los puestos actuales de ingeniería de datos.
- 🧱 **Infraestructura y herramientas:** Kubernetes, Docker y Terraform se relacionan con salarios más altos.
- 🔥 **Big data:** Apache Spark combina una demanda sólida con una remuneración competitiva.

---

## 💻 Técnicas de SQL aplicadas

### Diseño y optimización de consultas

- **Uniones complejas:** operaciones `INNER JOIN` entre `job_postings_fact`, `skills_job_dim` y `skills_dim`.
- **Agregaciones:** `COUNT()`, `MEDIAN()` y `ROUND()` para el análisis estadístico.
- **Filtros:** lógica booleana en cláusulas `WHERE`, con condiciones como `job_title_short`, `job_work_from_home` y `salary_year_avg IS NOT NULL`.
- **Orden y límites:** `ORDER BY`, `DESC` y `LIMIT` para obtener los primeros resultados.

### Técnicas de análisis de datos

- **Agrupación:** `GROUP BY` para analizar categorías por habilidad.
- **Funciones matemáticas:** `LN()` para aplicar el logaritmo natural y normalizar las métricas de demanda.
- **Métricas calculadas:** puntuación que combina la demanda transformada con el salario mediano.
- **Cláusula `HAVING`:** filtra resultados agregados, como habilidades con al menos 100 ofertas.
- **Tratamiento de `NULL`:** excluye registros incompletos con condiciones como `salary_year_avg IS NOT NULL`.