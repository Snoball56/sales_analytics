CREATE SCHEMA analytics;

SET search_path TO analytics;

CREATE TABLE dim_customer(
	customer_key INT PRIMARY KEY,
	customer_unique_id TEXT,
	customer_city TEXT,
	customer_state TEXT,
	customer_zip_code_prefix INT
);

CREATE TABLE dim_product(
	product_key INT PRIMARY KEY,
	product_ID TEXT,
	product_category_name TEXT
);

CREATE TABLE dim_date(
	date_key INT PRIMARY KEY,
	date TIMESTAMP,
	year INT,
	quarter INT,
	month INT,
	month_name TEXT,
	day INT,
	weekday INT,
	is_weekend BOOLEAN
);

CREATE TABLE fact_sales (
    sales_key INT PRIMARY KEY,
    date_key INT,
    customer_key INT,
    product_key INT,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),
    total_sales NUMERIC(10,2),
    CONSTRAINT fk_date
        FOREIGN KEY(date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_customer
        FOREIGN KEY(customer_key) REFERENCES dim_customer(customer_key),
    CONSTRAINT fk_product
        FOREIGN KEY(product_key) REFERENCES dim_product(product_key)
);

SELECT * FROM analytics.dim_customer LIMIT 5;
SELECT * FROM analytics.dim_product LIMIT 5;
SELECT * FROM analytics.dim_date LIMIT 5;
SELECT * FROM analytics.fact_sales LIMIT 5;

SELECT COUNT(*) FROM analytics.dim_customer; --96000
SELECT COUNT(*) FROM analytics.dim_product; --33000
SELECT COUNT(*) FROM analytics.dim_date; --634
SELECT COUNT(*) FROM analytics.fact_sales; --113300

--auf Duplikate prüfen
SELECT customer_unique_id, COUNT(*)
FROM dim_customer
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;

TRUNCATE TABLE analytics.dim_customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE analytics.dim_product RESTART IDENTITY CASCADE;
TRUNCATE TABLE analytics.dim_date RESTART IDENTITY CASCADE;
TRUNCATE TABLE analytics.fact_sales RESTART IDENTITY CASCADE;

TRUNCATE TABLE analytics.dim_date RESTART IDENTITY CASCADE;


SELECT d::date
FROM generate_series(
    (SELECT MIN(date) FROM analytics.dim_date),
    (SELECT MAX(date) FROM analytics.dim_date),
    '1 day'
) d
LEFT JOIN analytics.dim_date dd
ON d = dd.date
WHERE dd.date IS NULL;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'dim_date';

DROP TABLE public.dim_date;
DROP TABLE public.dim_customer;
DROP TABLE public.dim_product;
DROP TABLE public.fact_sales;

