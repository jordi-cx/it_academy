/*
Sprint 3 - BigQuery
IT Academy - Data Analytics
Jordi Calmet Xartó

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_03
*/

-- Nivell 1. Exercici 1

CREATE SCHEMA `sprint3-analytics-jordi-calmet.sprint3_silver`
OPTIONS (
  location = 'EU'
);


-- Nivell 1. Exercici 2

CREATE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.erp_transactions_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
  field_delimiter = ';',
  skip_leading_rows = 1
);

CREATE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.erp_companies_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);

CREATE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.crm_users_american_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/american_users.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);

CREATE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.crm_users_european_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/european_users.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);

CREATE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.crm_credit_cards_raw`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);


SELECT * FROM `sprint3-analytics-jordi-calmet.sprint3_bronze.erp_transactions_raw` 
LIMIT 5;


-- Nivell 1. Exercici 3

SELECT table_name, table_type
FROM sprint3_bronze.INFORMATION_SCHEMA.TABLES;


-- Nivell 1. Exercici 4

/*
Generate a SQL query to create a new table called erp_transactions_raw_native in the sprint3_bronze dataset. 
It should contain exactly all the same data from the erp_transactions_raw table (external table). 
Please use CREATE OR REPLACE TABLE so that I can run it more than once in case we get any errors.
*/

/*
Código SQL generado por Gemini:

CREATE OR REPLACE TABLE
  `sprint3-analytics-jordi-calmet`.`sprint3_bronze`.`erp_transactions_raw_native` AS
SELECT
  *
FROM
  `sprint3-analytics-jordi-calmet`.`sprint3_bronze`.`erp_transactions_raw`;
*/

-- Retoco un poco el código para que quede más compacto
CREATE OR REPLACE TABLE sprint3_bronze.erp_transactions_raw_native AS
SELECT * FROM sprint3_bronze.erp_transactions_raw;

-- Coste de las consultas en las diferentes tablas:

-- Tabla Externa
SELECT id FROM sprint3_bronze.erp_transactions_raw;
-- Bytes processed: 12.61 MB
-- Bytes billed: 13 MB

-- Tabla Nativa
SELECT id FROM sprint3_bronze.erp_transactions_raw_native;
-- Bytes processed: 3.62 MB
-- Bytes billed: 10 MB 


-- Cuidado con el LIMIT
SELECT * FROM sprint3_bronze.erp_transactions_raw_native;

SELECT * FROM sprint3_bronze.erp_transactions_raw_native 
LIMIT 10;

-- 10.87 MB

SELECT * FROM sprint3_bronze.erp_transactions_raw
ORDER BY id;

SELECT * FROM sprint3_bronze.erp_transactions_raw
ORDER BY id
LIMIT 10;

-- 12.61 MB


-- Nivell 1. Exercici 5
-- 5 dies amb més ingressos de l'any 2021

SELECT  DATE(timestamp) AS dia, 
        ROUND(SUM(amount), 2) AS total_amount
FROM sprint3_bronze.erp_transactions_raw_native
WHERE declined = 0
GROUP BY dia
ORDER BY total_amount DESC
LIMIT 5;

-- DATE(CAST(time_str AS TIMESTAMP)) AS dia
-- DATE(PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S %Z', time_str)) AS dia


-- Nivell 1. Exercici 6

-- He tenido que volver a crear la tabla externa companies
-- porque no me identificó correctamente las columnas:
-- company_id,company_name,phone,email,country,website
CREATE OR REPLACE EXTERNAL TABLE `sprint3-analytics-jordi-calmet.sprint3_bronze.erp_companies_raw`
(
  company_id STRING,
  company_name STRING,
  phone STRING,
  email STRING,
  country STRING,
  website STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);

/*
Llista el nom, país i data de les transaccions realitzades 
per empreses que van fer operacions entre 100 i 200 euros 
en alguna d'aquestes dates: 29-04-2015, 20-07-2018 o 13-03-2024
*/

SELECT c.company_name, c.country, DATE(t.timestamp) AS dia
FROM sprint3_bronze.erp_transactions_raw_native AS t
INNER JOIN sprint3_bronze.erp_companies_raw AS c
ON c.company_id = t.business_id
WHERE t.amount BETWEEN 100.00 AND 200.00
AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
AND t.declined = 0


-- Nivell 2. Exercici 1

CREATE OR REPLACE TABLE sprint3_silver.products_clean AS
SELECT 
    id AS product_id,
    product_name AS name,
    price, 
    colour, 
    weight, 
    warehouse_id
FROM 
    sprint3_bronze.erp_products_raw;


CREATE OR REPLACE TABLE sprint3_silver.products_clean AS
SELECT 
    product_id,
    name,
    price, 
    colour, 
    weight, 
    CAST(REPLACE(warehouse_id, 'WH-', '') AS INT64) AS warehouse_id
FROM 
    sprint3_silver.products_clean;


-- Aplicamos el valor absoluto a la columna porque aparecían algunos números negativos
-- debido a que en los datos originales había algunos guiones dobles (WH--)
CREATE OR REPLACE TABLE sprint3_silver.products_clean AS
SELECT 
    product_id,
    name,
    price, 
    colour, 
    weight, 
    ABS(warehouse_id) AS warehouse_id
FROM 
    sprint3_silver.products_clean;


-- Mostramos el tipo de dato de la columna price
SELECT column_name, data_type 
FROM sprint3_silver.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'products_clean' 
AND column_name = 'price';


-- Nivell 2. Exercici 2
-- erp_transactions_raw_native:
-- id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude

CREATE OR REPLACE TABLE sprint3_silver.transactions_clean AS
SELECT 
    id AS transaction_id,
    card_id, 
    business_id,
    CAST(timestamp AS TIMESTAMP) AS transaction_time, 
    IFNULL(SAFE_CAST(amount AS FLOAT64), 0) AS amount,
    declined,
    product_ids, 
    user_id,
    SAFE_CAST(lat AS FLOAT64) AS latitude,
    SAFE_CAST(longitude AS FLOAT64) AS longitude
FROM 
    sprint3_bronze.erp_transactions_raw_native;


-- Nivell 2. Exercici 3
-- sprint3_bronze.crm_users_american_raw, sprint3_bronze.crm_users_european_raw:
-- id, name, surname, phone, email, birth_date, country, city, postal_code, address
-- sprint3_silver.users_combined: 
-- user_id, ..., origin

CREATE OR REPLACE TABLE sprint3_silver.users_combined AS
SELECT
    id AS user_id, 
    name, surname, 
    phone, email, 
    birth_date, 
    country, city, postal_code, address,
    'American' AS origin
FROM
    sprint3_bronze.crm_users_american_raw
UNION ALL
SELECT
    id AS user_id, 
    name, surname, 
    phone, email, 
    birth_date, 
    country, city, postal_code, address,
    'European' AS origin
FROM
    sprint3_bronze.crm_users_european_raw;


SELECT origin, COUNT(*) AS total
FROM sprint3_silver.users_combined
GROUP BY origin;
-- American: 1010
-- European: 3990


-- Nivell 2. Exercici 4
-- sprint3_bronze.erp_companies_raw:
-- company_id, company_name, phone, email, country, website

CREATE OR REPLACE TABLE sprint3_silver.companies_clean AS
SELECT company_id, company_name, phone, email, country, website
FROM sprint3_bronze.erp_companies_raw;

-- sprint3_bronze.erp_credit_cards_raw:
-- id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date

CREATE OR REPLACE TABLE sprint3_silver.credit_cards_clean AS
SELECT  id AS credit_card_id, 
        user_id, iban, pan, 
        -- Forzamos 4 dígitos para el PIN i 3 para el CVV añadiendo ceros
        LPAD(CAST(pin AS STRING), 4, '0') AS pin, 
        LPAD(CAST(cvv AS STRING), 3, '0') AS cvv, 
        track1, track2,
        expiring_date
        -- Nos aseguramos que la fecha se identifique bien
        -- PARSE_DATE('%m/%d/%y', expiring_date) AS expiring_date
        -- CAST(expiring_date AS DATE) AS expiring_date
FROM sprint3_bronze.crm_credit_cards_raw;


-- Nivell 3. Exercici 1

CREATE OR REPLACE VIEW sprint3_gold.v_marketing_kpis AS
SELECT  c.company_name, c.phone, c.country,
        ROUND(AVG(t.amount), 2) AS avg_amount,
        CASE 
          WHEN AVG(t.amount) > 260.00 THEN 'Premium'
          ELSE 'Standard'
        END AS client_tier
FROM sprint3_silver.companies_clean c
INNER JOIN sprint3_silver.transactions_clean t
ON t.business_id = c.company_id
WHERE t.declined = 0
GROUP BY c.company_name, c.phone, c.country;

SELECT * FROM sprint3_gold.v_marketing_kpis
ORDER BY client_tier ASC, avg_amount DESC;


-- Nivell 3. Exercici 2

CREATE OR REPLACE TABLE sprint3_silver.transactions_clean AS
SELECT  transaction_id,
        card_id, business_id,
        transaction_time, 
        amount, declined,
        ARRAY(
          SELECT CAST(id AS INT64) 
          FROM UNNEST(SPLIT(product_ids, ', ')) AS id
        ) AS product_ids,
        user_id,
        latitude, longitude
FROM sprint3_silver.transactions_clean;


CREATE OR REPLACE TABLE sprint3_gold.product_sales_ranking AS
SELECT  p.product_id, 
        COUNT(t.transaction_id) AS total_sold,
        p.name, p.price, p.colour
FROM  sprint3_silver.transactions_clean t, 
      UNNEST(product_ids) AS product_unnested
LEFT JOIN sprint3_silver.products_clean p
ON p.product_id = product_unnested
GROUP BY p.product_id, p.name, p.price, p.colour;


SELECT * FROM sprint3_gold.product_sales_ranking
ORDER BY total_sold DESC;


-- Nivell 3. Exercici 3
-- Save Results -> Google Sheets