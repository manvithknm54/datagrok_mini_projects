-- Week 6 Data Engineering SQL Pipeline | PostgreSQL 15+
DROP SCHEMA IF EXISTS datagrokr_week6 CASCADE;
CREATE SCHEMA datagrokr_week6;
SET search_path TO datagrokr_week6;

CREATE TABLE dim_customer (
 customer_key BIGSERIAL PRIMARY KEY, customer_id INT NOT NULL,
 customer_name VARCHAR(100) NOT NULL, city VARCHAR(80), state VARCHAR(80),
 valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
 valid_to DATE NOT NULL DEFAULT DATE '9999-12-31', is_current BOOLEAN NOT NULL DEFAULT TRUE,
 UNIQUE(customer_id, valid_from), CHECK(valid_to >= valid_from)
);
CREATE UNIQUE INDEX uq_customer_current ON dim_customer(customer_id) WHERE is_current;

CREATE TABLE dim_product (
 product_key BIGSERIAL PRIMARY KEY, product_id INT NOT NULL UNIQUE,
 product_name VARCHAR(120) NOT NULL, category VARCHAR(80) NOT NULL,
 unit_price NUMERIC(12,2) NOT NULL CHECK(unit_price >= 0)
);
CREATE TABLE fact_sales (
 sale_id BIGINT NOT NULL, sale_date DATE NOT NULL, order_id INT NOT NULL,
 customer_key BIGINT NOT NULL REFERENCES dim_customer(customer_key),
 product_key BIGINT NOT NULL REFERENCES dim_product(product_key),
 quantity INT NOT NULL CHECK(quantity > 0), amount NUMERIC(14,2) NOT NULL CHECK(amount >= 0),
 source VARCHAR(30) NOT NULL DEFAULT 'csv',
 PRIMARY KEY(sale_id, sale_date)
) PARTITION BY RANGE(sale_date);
CREATE TABLE fact_sales_2026_q1 PARTITION OF fact_sales
 FOR VALUES FROM ('2026-01-01') TO ('2026-04-01');
CREATE TABLE fact_sales_2026_q2 PARTITION OF fact_sales
 FOR VALUES FROM ('2026-04-01') TO ('2026-07-01');
CREATE TABLE fact_sales_default PARTITION OF fact_sales DEFAULT;
CREATE INDEX idx_fact_customer_date ON fact_sales(customer_key, sale_date);
CREATE INDEX idx_fact_product_date ON fact_sales(product_key, sale_date);

CREATE TABLE stg_sales (
 sale_id BIGINT, sale_date DATE, order_id INT, customer_id INT, product_id INT,
 quantity INT, amount NUMERIC(14,2), source VARCHAR(30)
);
CREATE TABLE etl_audit (
 audit_id BIGSERIAL PRIMARY KEY, event_time TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
 event_name VARCHAR(100) NOT NULL, rows_affected INT, notes TEXT
);
