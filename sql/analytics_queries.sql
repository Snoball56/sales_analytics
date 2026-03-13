SET search_path TO analytics;

--Umsatz nach Zeit
SELECT
    d.year,
    d.month,
    SUM(f.total_sales) AS revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

--Umsatz nach Bundesstaat
SELECT
    c.customer_state,
    SUM(f.total_sales) AS revenue
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY c.customer_state
ORDER BY revenue DESC;

--Umsatz nach Produktkategorie
SELECT 
	p.product_category_name,
	SUM(f.total_sales) AS revenue
FROM fact_sales f
JOIN dim_product p
	ON f.product_key = p.product_key
GROUP BY p.product_category_name
ORDER BY revenue DESC;

--Durchschnittlicher Bestellwert
SELECT
	AVG(total_sales) AS average_order_value
FROM fact_sales;

--Umsatzwachstum Monat zu Monat
WITH monthly_revenue AS (
	SELECT 
		d.year,
		d.month,
		SUM(f.total_sales) AS revenue
	FROM fact_sales f
	JOIN dim_date d
		ON f.date_key = d.date_key
	GROUP BY d.year, d.month
)
SELECT 
	year, 
	month, 
	revenue,
	LAG(revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
	ROUND(
		(revenue - LAG(revenue) OVER (ORDER BY year, month))
		/ NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0)*100, 2
	) AS mom_growth_percent
FROM monthly_revenue
ORDER BY year, month;

--Top 10 Städte nach Umsatz
-- Jede Spalte in SELECT, die nicht aggregiert wird, muss in GROUP BY.
SELECT
	c.customer_city,
	c.customer_state,
	SUM(f.total_sales) AS revenue
FROM fact_sales f
JOIN dim_customer c
	ON f.customer_key = c.customer_key
GROUP BY c.customer_city, c.customer_state
ORDER BY revenue DESC
LIMIT 10;

--Pareto-Analyse der Produktkategorien
WITH category_revenue AS (
	SELECT
		p.product_category_name,
		SUM(f.total_sales) AS revenue
	FROM fact_sales f
	JOIN dim_product p
		ON f.product_key = p.product_key
	GROUP BY p.product_category_name
),
ranked_categories AS (
	SELECT
		product_category_name,
		revenue,
		SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
		SUM(revenue) OVER () AS total_revenue
	FROM category_revenue
)
SELECT
	product_category_name,
	revenue,
	cumulative_revenue,
	ROUND(cumulative_revenue / total_revenue * 100, 2) AS cumulative_revnue_percentage
FROM ranked_categories
ORDER BY revenue DESC;

