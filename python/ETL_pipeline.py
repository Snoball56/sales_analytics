#!/usr/bin/env python
# coding: utf-8


import pandas as pd
from sqlalchemy import create_engine

DATA_PATH = "../data/"

def main():
    
    print("Laden der Rohdaten...")
    
    customers = pd.read_csv(DATA_PATH + "customers_dataset.csv")
    orders = pd.read_csv(DATA_PATH + "orders_dataset.csv")
    order_items = pd.read_csv(DATA_PATH + "order_items_dataset.csv")
    products = pd.read_csv(DATA_PATH + "products_dataset.csv")
    payments = pd.read_csv(DATA_PATH + "order_payments_dataset.csv")
    reviews = pd.read_csv(DATA_PATH + "order_reviews_dataset.csv")

    print("Transformieren der Daten...")
    
    # Datumswerte anpassen
    orders['order_purchase_timestamp'] = pd.to_datetime(
        orders['order_purchase_timestamp']
    )
    
    
    # dim_customer erstellen
    dim_customer = customers[['customer_unique_id', 'customer_city', 'customer_state', 'customer_zip_code_prefix']].drop_duplicates(subset=['customer_unique_id']).reset_index(drop=True)
    
    dim_customer['customer_key'] = dim_customer.index + 1
    
    dim_customer = dim_customer[
        [
            'customer_key', 
            'customer_unique_id', 
            'customer_city', 
            'customer_state', 
            'customer_zip_code_prefix'
        ]
    ]
    
    
    dim_customer['customer_unique_id'].duplicated().sum()   
    
    # dim_product erstellen
    dim_product = products[['product_id', 'product_category_name']].copy()
    dim_product['product_category_name'] = dim_product['product_category_name'].fillna('unknown')
    dim_product = dim_product.drop_duplicates().reset_index(drop=True) #Nach drop_duplicates() können Lücken im Index entstehen.
    dim_product['product_key'] = dim_product.index + 1 #Indizes starten bei 0, aber Keys normalerweise bei 1. Künstlicher Schlüssel für Faktentabelle.
    dim_product = dim_product[
        [
        'product_key', 
        'product_id', 
        'product_category_name']
    ]   
    

    # dim_date erstellen
    date_range = pd.date_range(
        start=orders['order_purchase_timestamp'].min().normalize(),
        end=orders['order_purchase_timestamp'].max().normalize(),
        freq='D'
    )
    
    dim_date = pd.DataFrame({'date': date_range})
    
    dim_date['year'] = dim_date['date'].dt.year
    dim_date['month'] = dim_date['date'].dt.month
    dim_date['day'] = dim_date['date'].dt.day
    dim_date['quarter'] = dim_date['date'].dt.quarter
    dim_date['weekday'] = dim_date['date'].dt.weekday
    dim_date['month_name'] = dim_date['date'].dt.month_name()
    dim_date['is_weekend'] = dim_date['weekday'].isin([5, 6])
    
    dim_date['date_key'] = dim_date.index + 1
    
    dim_date = dim_date[
        ['date_key', 
         'date', 
         'year', 
         'quarter', 
         'month', 
         'month_name', 
         'day', 
         'weekday', 
         'is_weekend']
    ]
    
  
    # Fehlende Tage prüfen
    all_dates = pd.date_range(
        start=dim_date['date'].min(),
        end=dim_date['date'].max(),
        freq='D'
    )
    
    missing_dates = set(all_dates) - set(dim_date['date'])
    
    print("Missing days:", len(missing_dates))

    
    # fact_table erstellen
    order_items['total_sales'] = order_items['price'] + order_items['freight_value']
    
    fact = order_items.merge(
        orders[['order_id', 'customer_id', 'order_purchase_timestamp']],
        on='order_id',
        how='left'
    )
    
    fact = fact.merge(
        customers[['customer_id', 'customer_unique_id']],
        on='customer_id',
        how='left'
    )
    
    # Surrogate Keys holen
    fact = fact.merge(
        dim_customer[['customer_key', 'customer_unique_id']],
        on = 'customer_unique_id',
        how = 'left'
    )
    
    # Product_key anbinden
    fact = fact.merge(
        dim_product[['product_key', 'product_id']],
        on = 'product_id',
        how='left'
    )
    
    fact['order_date'] = fact['order_purchase_timestamp'].dt.normalize()
    
    fact = fact.merge(
        dim_date[['date_key', 'date']],
        left_on = 'order_date',
        right_on = 'date',
        how = 'left'
    )
    
    fact_sales = fact[
        [
        'date_key',
        'customer_key',
        'product_key',
        'price',
        'freight_value',
        'total_sales'
        ]
    ].copy()
    
    #fact_sales um eine echte ID erweitern
    fact_sales = fact_sales.reset_index(drop=True)
    fact_sales['sales_key'] = fact_sales.index + 1
    
    fact_sales = fact_sales[
        [
        'sales_key', 
        'date_key', 
        'customer_key',
        'product_key',
        'price',
        'freight_value',
        'total_sales']
    ]
    
 
    # In Postgres laden
    print("Laden der Daten nach PostgreSQL...")
    
    engine = create_engine("postgresql+psycopg2://postgres:Postgres34@localhost:5433/olist_analytics_dwh")
    
    dim_customer.to_sql(
        "dim_customer", 
        engine, 
        schema = "analytics", 
        if_exists="append", 
        index = False
    )
    
    dim_product.to_sql(
        "dim_product", 
        engine, 
        schema = "analytics", 
        if_exists="append", 
        index=False
    )
    
    dim_date.to_sql(
        "dim_date", 
        engine, 
        schema = "analytics", 
        if_exists="append", 
        index=False
    )
    
    fact_sales.to_sql(
        "fact_sales", 
        engine, 
        schema = "analytics", 
        if_exists="append", 
        index=False
    )
    
    print("ETL abgeschlossen.")


if __name__ == "__main__":
    main()

