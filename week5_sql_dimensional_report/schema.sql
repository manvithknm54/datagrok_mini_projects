-- Week 5: SQL Dimensional Model
-- PostgreSQL 15+

DROP SCHEMA IF EXISTS datagrokr_week5 CASCADE;
CREATE SCHEMA datagrokr_week5;
SET search_path TO datagrokr_week5;

CREATE TABLE dim_customer (
    customer_key   SERIAL PRIMARY KEY,
    customer_id    INT NOT NULL UNIQUE,
    customer_name  VARCHAR(100) NOT NULL,
    city           VARCHAR(80),
    state          VARCHAR(80),
    country        VARCHAR(80)
);

CREATE TABLE dim_product (
    product_key    SERIAL PRIMARY KEY,
    product_id     INT NOT NULL UNIQUE,
    product_name   VARCHAR(120) NOT NULL,
    category       VARCHAR(80) NOT NULL,
    subcategory    VARCHAR(80),
    unit_price     NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE dim_date (
    date_key       INT PRIMARY KEY,
    full_date      DATE NOT NULL UNIQUE,
    year           INT NOT NULL,
    quarter        INT NOT NULL,
    month          INT NOT NULL,
    month_name     VARCHAR(20) NOT NULL
);

CREATE TABLE fact_sales (
    sales_key      BIGSERIAL PRIMARY KEY,
    order_id       INT NOT NULL UNIQUE,
    date_key       INT NOT NULL REFERENCES dim_date(date_key),
    customer_key   INT NOT NULL REFERENCES dim_customer(customer_key),
    product_key    INT NOT NULL REFERENCES dim_product(product_key),
    quantity       INT NOT NULL CHECK (quantity > 0),
    sales_amount   NUMERIC(14,2) NOT NULL CHECK (sales_amount >= 0)
);

CREATE INDEX idx_fact_sales_date_customer
    ON fact_sales(date_key, customer_key);

CREATE INDEX idx_fact_sales_product
    ON fact_sales(product_key);
