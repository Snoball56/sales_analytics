#**Project Overview**

This project builds an end-to-end analytics pipeline for an e-commerce dataset from the Brazilian Olist platform.

The goal of the project is to transform raw transactional data into a structured data warehouse and create an interactive business intelligence dashboard that supports data-driven decision making.

The workflow includes:

Python for ETL and data transformation

PostgreSQL for the data warehouse

SQL for analytical queries

Power BI for interactive data visualization



#**Business Questions**

The dashboard answers key business questions such as:

How does revenue evolve over time?

What is the month-over-month revenue growth?

Which product categories generate the most revenue?

Which regions and states contribute most to revenue?

How are customers distributed geographically?


#**Data Pipeline**

The project implements a full analytics workflow:

Raw CSV data -> Python ETL Pipeline -> PostgreSQL Data Warehouse -> SQL Analytics -> Power BI Dashboard


#**Data Model**

The project uses a star schema consisting of one fact table and three dimension tables.

Fact table: 

- fact_sales

Dimension tables:

- dim_customer
- dim_product
- dim_date


#**Project Structure**

sales_analytics/
│
├── README.md
├── requirements.txt
│
├── data/
│   └── raw/
│       ├── customers_dataset.csv
│       ├── orders_dataset.csv
│       ├── order_items_dataset.csv
│       ├── products_dataset.csv
│       ├── order_payments_dataset.csv
│       └── order_reviews_dataset.csv
│
├── python/
│   └── etl_pipeline.py
│
├── sql/
│   ├── create_tables.sql
│   └── analytics_queries.sql
│
├── powerbi/
│   └── sales_analytics.pbix
│
└── images/


#**Setup instructions**

1. Run the SQL Script to create the schema and tables in PostgreSQL.

2. Run the ETL pipeline.

3. Open the PowerBI dashboard.


#**SQL Analytics**

Example analytical queries used:

- Revenue by state

- Top product categories by revenue

- Monthly revenue trend 

- Month-over-month revenue growth

- Customer distribution by region

##**Example:**

SELECT
    c.customer_state,
    SUM(f.total_sales) AS revenue
FROM analytics.fact_sales f
JOIN analytics.dim_customer c
ON f.customer_key = c.customer_key
GROUP BY c.customer_state
ORDER BY revenue DESC;


#**Dashboard pages**

##Page 1: Sales Performance Overview

Key metrics:

- Total Revenue
- Total Orders
- Average Order Value
- Revenue Trend over Time
- Top 10 Product Categories
- Revenue by geography

##Page 2: Sales Insights

- Revenue by State
- Orders by State
- Month-over-month Revenue Growth


#**Dashboard Preview**

![Dashboard]images/Page1_Sales_Overview.png
![Dashboard]images/Page2_Sales_Insights.png


#**Dataset**

Source: Olist Brazilian E-Commerce Public Dataset (Kaggle)


#**Key Insights**

These are some insights derived from the analysis:

- Revenue shows strong growth during 2017 and 2018.

- The state of São Paulo generates the highest revenue.

- Product categories such as furniture and electronics are major revenue drivers.

- Customer and revenue distribution vary significantly across Brazilian regions.



