/*
Sprint 4 - BigQuery
IT Academy - Data Analytics
Jordi Calmet Xartó

https://github.com/jordi-cx/it_academy/tree/main/data_analytics/sprint_04
*/

-- Nivell 1. Exercici 1
SELECT * 
FROM sprint3_silver.transactions_clean t
INNER JOIN sprint3_silver.companies_clean c
ON t.business_id = c.company_id
-- WHERE EXTRACT(YEAR FROM TIMESTAMP(timestamp)) = 2022
WHERE DATE(t.transaction_time) = '2022-03-12'
AND c.country = 'Germany';


-- Nivell 1. Exercici 2.1
CREATE OR REPLACE TABLE sprint3_silver.transactions_recent AS
SELECT * EXCEPT(transaction_time),
	TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL CAST(RAND() * 4320000 AS INT64) SECOND) AS transaction_time
FROM sprint3_silver.transactions_clean;

/*
Otras posibilidades:
TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL CAST(RAND() * 50 AS INT64) DAY)
TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL CAST(RAND() * 50 AS INT64) DAY) AS transaction_time
TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL CAST(RAND() * 72000 AS INT64) MINUTE) AS transaction_time
DATE_ADD(DATE '2023-01-01', INTERVAL CAST(RAND() * 100 AS INT64) DAY) AS random_date
*/

-- Nivell 1. Exercici 2.2
CREATE OR REPLACE TABLE sprint3_gold.fact_transactions_optimized
PARTITION BY DATE(transaction_time)
CLUSTER BY business_id
AS SELECT * 
FROM sprint3_silver.transactions_recent;


-- Nivell 1. Exercici 3
SELECT * FROM sprint3_silver.transactions_recent
WHERE DATE(transaction_time) > '2026-03-21';
-- 11.85 MB

SELECT * FROM sprint3_gold.fact_transactions_optimized
WHERE DATE(transaction_time) > '2026-03-21';
-- 7.21 MB


-- Nivell 1. Exercici 4
CREATE OR REPLACE MATERIALIZED VIEW sprint3_gold.mv_daily_sales
PARTITION BY DATE(transaction_time) AS
SELECT 	TIMESTAMP_TRUNC(transaction_time, DAY) AS transaction_time,
    	SUM(amount) AS daily_sales
FROM sprint3_gold.fact_transactions_optimized
WHERE declined = 0
GROUP BY transaction_time;

-- SELECT * FROM sprint3_gold.mv_daily_sales
-- ORDER BY transaction_time;

SELECT	DATE(transaction_time) AS day,
		ROUND(daily_sales, 2) AS total_sales 
FROM sprint3_gold.mv_daily_sales
ORDER BY transaction_time;


-- Nivell 2. Exercici 1
WITH vip_stats AS (
SELECT 	user_id,
		CONCAT(u.name, ' ', u.surname) AS full_name, 
		u.email AS e_mail, 
		COUNT(t.transaction_id) AS num_sales, 
		ROUND(AVG(t.amount), 2) AS avg_sale, 
		MAX(t.amount) AS max_sale, 
		ROUND(SUM(t.amount), 2) AS total_spent
FROM sprint3_silver.transactions_recent t
INNER JOIN sprint3_silver.users_combined u
USING (user_id)
WHERE t.declined = 0
GROUP BY user_id, full_name, e_mail
HAVING total_spent > 500.00
)
SELECT * FROM vip_stats
ORDER BY total_spent DESC;


-- Nivell 2. Exercici 2
WITH cte_daily AS (
	SELECT  
        DATE(transaction_time) AS sales_date,
        ROUND(daily_sales, 2) AS sold_this_day,
        ROUND(LAG(daily_sales) OVER(ORDER BY DATE(transaction_time) ASC), 2) AS sold_day_before
    FROM 
        sprint3_gold.mv_daily_sales
)
SELECT 
    sales_date,
    sold_this_day,
    sold_day_before,
    ROUND(SAFE_DIVIDE((sold_this_day - sold_day_before), sold_day_before) * 100, 2) AS percent_diff
FROM 
    cte_daily
ORDER BY 
    sales_date ASC;


-- Nivell 2. Exercici 3
WITH cte_ytd AS (
	SELECT	DATE(transaction_time) AS sales_date,
        	ROUND(daily_sales, 2) AS sold_this_day
  	FROM sprint3_gold.mv_daily_sales
)
SELECT 	sales_date, 
		sold_this_day,
		ROUND(SUM(sold_this_day) OVER (
        PARTITION BY EXTRACT(YEAR FROM sales_date) 
        ORDER BY sales_date ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS ytd_sales
FROM cte_ytd
ORDER BY sales_date ASC;


-- Nivell 2. Exercici 4
WITH first_three_sales AS (
    SELECT 
        u.user_id,
        CONCAT(u.name, ' ', u.surname) AS full_name,
        u.email AS e_mail,
        t.amount,
        t.transaction_time,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_time ASC) 
        AS sale_rank
FROM sprint3_silver.transactions_clean t
INNER JOIN sprint3_silver.users_combined u 
USING (user_id)
WHERE t.declined = 0
QUALIFY sale_rank <= 3
)
SELECT 
    user_id,
    full_name,
    e_mail,
    MAX(CASE WHEN sale_rank = 3 THEN DATE(transaction_time) END) AS third_sale_date,
    MAX(CASE WHEN sale_rank = 3 THEN amount END) AS third_sale_amount,
    ROUND(AVG(amount), 2) AS avg_three_sales
FROM 
    first_three_sales
GROUP BY 
    user_id, full_name, e_mail
HAVING 
    COUNT(*) = 3
ORDER BY 
    avg_three_sales DESC;


-- Nivell 3. Exercici 1
CREATE OR REPLACE TABLE sprint3_silver.dim_transactions_flat AS
SELECT 
    t.transaction_id,
    t.transaction_time,
    t.amount AS total_ticket,
    p.product_id,
    p.name AS product_name,
    p.price
FROM 
    sprint3_silver.transactions_clean t
CROSS JOIN 
    UNNEST(t.product_ids) AS product_unnested
INNER JOIN 
    sprint3_silver.products_clean p
    ON product_unnested = p.product_id
WHERE t.declined = 0;


SELECT * FROM sprint3_silver.dim_transactions_flat
ORDER BY transaction_id;


-- Nivell 3. Exercici 2
SELECT product_name, COUNT(*) AS product_sales
FROM sprint3_silver.dim_transactions_flat
GROUP BY product_name
ORDER BY product_sales DESC
LIMIT 5;


-- Nivell 3. Exercici 3
CREATE OR REPLACE FUNCTION sprint3_silver.calculate_tax(amount FLOAT64) 
AS (amount * 1.21;


CREATE OR REPLACE TABLE sprint3_silver.dim_transactions_flat AS
SELECT 
    t.transaction_id,
    t.transaction_time,
    t.amount AS total_ticket,
    p.product_id,
    p.name AS product_name,
    p.price AS product_price,
    ROUND(sprint3_silver.calculate_tax(p.price), 2) AS product_price_tax_inc
FROM 
    sprint3_silver.transactions_clean t
CROSS JOIN 
    UNNEST(t.product_ids) AS product_unnested
INNER JOIN 
    sprint3_silver.products_clean p
    ON product_unnested = p.product_id
WHERE t.declined = 0;


-- Fin
