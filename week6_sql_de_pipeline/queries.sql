SET search_path TO datagrokr_week6;

-- 1. Data quality checks
SELECT 'duplicate_sale_keys' AS check_name,COUNT(*) AS issue_count FROM
 (SELECT sale_id,sale_date FROM stg_sales GROUP BY sale_id,sale_date HAVING COUNT(*)>1) d
UNION ALL
SELECT 'unknown_customer_ids',COUNT(*) FROM stg_sales s LEFT JOIN dim_customer c
 ON c.customer_id=s.customer_id AND c.is_current WHERE c.customer_key IS NULL
UNION ALL
SELECT 'unknown_product_ids',COUNT(*) FROM stg_sales s LEFT JOIN dim_product p
 ON p.product_id=s.product_id WHERE p.product_key IS NULL;

-- 2. Monthly revenue by source
SELECT DATE_TRUNC('month',sale_date)::date AS sales_month,source,
 SUM(amount) AS revenue,COUNT(*) AS sales_count
FROM fact_sales GROUP BY 1,2 ORDER BY 1,2;

-- 3. UPSERT a new product or update its details if it exists
INSERT INTO dim_product(product_id,product_name,category,unit_price)
VALUES(107,'Laptop Sleeve','Accessories',1800)
ON CONFLICT(product_id) DO UPDATE SET product_name=EXCLUDED.product_name,
 category=EXCLUDED.category,unit_price=EXCLUDED.unit_price;

-- 4. MERGE product price updates
MERGE INTO dim_product AS target
USING (VALUES (102,'Wireless Mouse','Electronics',1250.00::numeric),
              (106,'USB-C Hub','Electronics',3200.00::numeric))
 AS src(product_id,product_name,category,unit_price)
ON target.product_id=src.product_id
WHEN MATCHED THEN UPDATE SET product_name=src.product_name,category=src.category,unit_price=src.unit_price
WHEN NOT MATCHED THEN INSERT(product_id,product_name,category,unit_price)
 VALUES(src.product_id,src.product_name,src.category,src.unit_price);

-- 5. SCD Type 2: expire the current customer version and add a new one
BEGIN;
UPDATE dim_customer SET valid_to=DATE '2026-05-31',is_current=FALSE
WHERE customer_id=2 AND is_current=TRUE;
INSERT INTO dim_customer(customer_id,customer_name,city,state,valid_from,valid_to,is_current)
VALUES(2,'Asha Rao','Bengaluru','Karnataka',DATE '2026-06-01',DATE '9999-12-31',TRUE)
ON CONFLICT(customer_id,valid_from) DO NOTHING;
COMMIT;

-- 6. JSONB event representation
SELECT jsonb_build_object('order_id',order_id,'sale_date',sale_date,
 'amount',amount,'source',source) AS sale_event
FROM fact_sales ORDER BY sale_date LIMIT 3;

-- 7. EXPLAIN ANALYZE: date filtering and partition pruning
EXPLAIN (ANALYZE,BUFFERS)
SELECT SUM(amount) FROM fact_sales
WHERE sale_date>=DATE '2026-01-01' AND sale_date<DATE '2026-04-01';

-- 8. EXPLAIN ANALYZE: customer/date composite index
EXPLAIN (ANALYZE,BUFFERS)
SELECT sale_id,sale_date,amount FROM fact_sales
WHERE customer_key=1 AND sale_date>=DATE '2026-01-01' AND sale_date<DATE '2026-04-01';

-- 9. Transaction control; ROLLBACK leaves prices unchanged
BEGIN;
UPDATE dim_product SET unit_price=unit_price*1.02 WHERE category='Furniture';
SELECT product_name,unit_price FROM dim_product WHERE category='Furniture';
ROLLBACK;

-- 10. Final customer/category report
SELECT c.customer_name,p.category,SUM(f.quantity) AS units_sold,SUM(f.amount) AS total_revenue
FROM fact_sales f JOIN dim_customer c ON c.customer_key=f.customer_key
JOIN dim_product p ON p.product_key=f.product_key
GROUP BY c.customer_name,p.category ORDER BY total_revenue DESC;
