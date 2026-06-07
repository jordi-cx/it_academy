/*
Sprint 9 - Visualizations
IT Academy - Data Analytics
Jordi Calmet Xartó

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_09_jcx
*/

-- EXTERNAL TABLES

/*
gsutil cat gs://bootcamp-data-analytics-public/CRM/american_users.csv | head -n 5
*/

CREATE OR REPLACE EXTERNAL TABLE `sprint9-visuals-jordi-calmet.sprint9_data.transactions_ext`
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
  field_delimiter = ';'
);

DROP TABLE IF EXISTS `sprint9-visuals-jordi-calmet.sprint9_data.transactions_raw`;


CREATE OR REPLACE EXTERNAL TABLE `sprint9-visuals-jordi-calmet.sprint9_data.companies_ext` (
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

DROP TABLE IF EXISTS `sprint9-visuals-jordi-calmet.sprint9_data.companies_raw`;

-- gsutil cat gs://bootcamp-data-analytics-public/CRM/american_users.csv | head -n 5
-- gsutil cat gs://bootcamp-data-analytics-public/CRM/european_users.csv | head -n 5
-- gsutil cat gs://bootcamp-data-analytics-public/CRM/credit_cards.csv | head -n 5

CREATE OR REPLACE EXTERNAL TABLE `sprint9-visuals-jordi-calmet.sprint9_data.users_american_ext` (
  id INT64,
  name STRING,
  surname STRING,
  phone STRING,
  email STRING,
  birth_date STRING,
  country STRING,
  city STRING,
  postal_code STRING,
  address STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/american_users.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);

DROP TABLE IF EXISTS `sprint9-visuals-jordi-calmet.sprint9_data.american_users_ext`;


CREATE OR REPLACE EXTERNAL TABLE `sprint9-visuals-jordi-calmet.sprint9_data.credit_cards_ext` (
  id STRING,
  user_id INT64,
  iban STRING,
  pan STRING,
  pin STRING,
  cvv STRING,
  track1 STRING,
  track2 STRING,
  expiring_date STRING
)
OPTIONS (
  format = 'CSV',
  uris = ['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv'],
  field_delimiter = ',',
  skip_leading_rows = 1
);


DROP TABLE IF EXISTS `sprint9-visuals-jordi-calmet.sprint9_data.credit_cards_raw`;

-- NATIVE TABLES

SELECT table_name, table_type 
FROM sprint9_data.INFORMATION_SCHEMA.TABLES;

-- transactions_nat, companies_nat, credit_cards_nat, products_nat
-- users_american_nat, users_european_nat


-- DATA SET CLEAN FOR ANALYSIS

CREATE OR REPLACE TABLE sprint9_analytics.products_clean AS
SELECT 
    id AS product_id,
    product_name AS name,
    CAST(REPLACE(price, '$', '') AS FLOAT64) AS price, 
    colour AS color, 
    weight, 
    CAST(REGEXP_REPLACE(CAST(warehouse_id AS STRING), r'[^0-9]', '') AS INT64) AS warehouse_id,
    category,
    brand,
    CAST(REPLACE(cost, '$', '') AS FLOAT64) AS cost,
    CAST(launch_date AS DATE) AS launch_date
FROM 
    sprint9_data.products_nat;


CREATE OR REPLACE TABLE sprint9_analytics.transactions_clean AS
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
    SAFE_CAST(longitude AS FLOAT64) AS longitude,
    IFNULL(SAFE_CAST(discount_amount AS FLOAT64), 0) AS discount_amount,
    IFNULL(SAFE_CAST(tax_amount AS FLOAT64), 0) AS tax_amount,
    IFNULL(SAFE_CAST(shipping_amount AS FLOAT64), 0) AS shipping_amount,
    channel,
    campaign_id,
    device_type,
    is_international,
    decline_reason,
    IFNULL(SAFE_CAST(distance_km AS FLOAT64), 0) AS distance_km
FROM 
    sprint9_data.transactions_nat;


CREATE OR REPLACE TABLE sprint9_analytics.users_all_clean AS
SELECT
    id AS user_id, 
    name, surname, 
    phone, email, 
    SAFE.PARSE_DATE('%b %d, %Y', birth_date) AS birth_date, 
    country, city, postal_code, address,
    'America' AS region,
    SAFE_CAST(signup_date AS DATE) AS signup_date,
    user_segment,
    income_band
FROM
    sprint9_data.users_american_nat
UNION ALL
SELECT
    id AS user_id, 
    name, surname, 
    phone, email, 
    SAFE.PARSE_DATE('%b %d, %Y', birth_date) AS birth_date, 
    country, city, postal_code, address,
    'Europe' AS region,
    SAFE_CAST(signup_date AS DATE) AS signup_date,
    user_segment,
    income_band
FROM
    sprint9_data.users_european_nat;


CREATE OR REPLACE TABLE sprint9_analytics.credit_cards_clean AS
SELECT 
    id AS card_id,
    user_id,
    iban, pan, pin, cvv,
    track1, track2,
    SAFE.PARSE_DATE('%m/%d/%y', expiring_date) AS expiring_date,
    card_type,
    card_renewal_flag
FROM 
    sprint9_data.credit_cards_nat;


CREATE OR REPLACE TABLE sprint9_analytics.companies_clean AS
SELECT 
    company_id, company_name,
    phone, email, country, website,
    merchant_category, merchant_price_position
FROM 
    sprint9_data.companies_nat;

--