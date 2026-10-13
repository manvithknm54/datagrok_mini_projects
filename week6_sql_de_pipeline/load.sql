-- Execute using psql -f load.sql from this directory.
SET search_path TO datagrokr_week6;
TRUNCATE TABLE stg_sales;
\copy datagrokr_week6.stg_sales(sale_id,sale_date,order_id,customer_id,product_id,quantity,amount,source) FROM 'sales_input.csv' WITH (FORMAT csv, HEADER true);

-- Review invalid rows before merging.
SELECT * FROM stg_sales
WHERE sale_id IS NULL OR sale_date IS NULL OR customer_id IS NULL OR product_id IS NULL
 OR quantity <= 0 OR amount < 0;

MERGE INTO fact_sales AS target
USING (
 SELECT s.sale_id,s.sale_date,s.order_id,c.customer_key,p.product_key,
        s.quantity,s.amount,s.source
 FROM stg_sales s
 JOIN dim_customer c ON c.customer_id=s.customer_id AND c.is_current=TRUE
 JOIN dim_product p ON p.product_id=s.product_id
) AS incoming
ON target.sale_id=incoming.sale_id AND target.sale_date=incoming.sale_date
WHEN MATCHED THEN UPDATE SET order_id=incoming.order_id, customer_key=incoming.customer_key,
 product_key=incoming.product_key, quantity=incoming.quantity, amount=incoming.amount, source=incoming.source
WHEN NOT MATCHED THEN INSERT(sale_id,sale_date,order_id,customer_key,product_key,quantity,amount,source)
 VALUES(incoming.sale_id,incoming.sale_date,incoming.order_id,incoming.customer_key,
 incoming.product_key,incoming.quantity,incoming.amount,incoming.source);

INSERT INTO etl_audit(event_name,rows_affected,notes)
SELECT 'FACT_SALES_MERGE',COUNT(*),'Merged staged records into partitioned fact table' FROM stg_sales;

SELECT tableoid::regclass AS partition_name,COUNT(*) AS row_count,SUM(amount) AS revenue
FROM fact_sales GROUP BY tableoid ORDER BY partition_name;
