-- Week 5: Dimensional Model + Advanced SQL Report
SET search_path TO datagrokr_week5;

-- 01. Scalar subquery: products priced above the average product price
SELECT product_name, unit_price
FROM dim_product
WHERE unit_price > (SELECT AVG(unit_price) FROM dim_product)
ORDER BY unit_price DESC;

-- 02. Correlated subquery: customers whose spend is above their customer average
SELECT c.customer_name,
       SUM(f.sales_amount) AS total_spend
FROM dim_customer c
JOIN fact_sales f ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.customer_name
HAVING SUM(f.sales_amount) >
       (SELECT AVG(customer_total)
        FROM (
            SELECT customer_key, SUM(sales_amount) AS customer_total
            FROM fact_sales
            GROUP BY customer_key
        ) x)
ORDER BY total_spend DESC;

-- 03. EXISTS: customers with at least one purchase
SELECT c.customer_id, c.customer_name
FROM dim_customer c
WHERE EXISTS (
    SELECT 1 FROM fact_sales f
    WHERE f.customer_key = c.customer_key
)
ORDER BY c.customer_id;

-- 04. NOT EXISTS: products never ordered
SELECT p.product_id, p.product_name
FROM dim_product p
WHERE NOT EXISTS (
    SELECT 1 FROM fact_sales f
    WHERE f.product_key = p.product_key
);

-- 05. RANK: rank products by total sales
WITH product_sales AS (
    SELECT p.product_name, SUM(f.sales_amount) AS total_sales
    FROM fact_sales f
    JOIN dim_product p ON p.product_key = f.product_key
    GROUP BY p.product_key, p.product_name
)
SELECT product_name, total_sales,
       RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM product_sales
ORDER BY sales_rank;

-- 06. DENSE_RANK by category
WITH category_product_sales AS (
    SELECT p.category, p.product_name, SUM(f.sales_amount) AS total_sales
    FROM fact_sales f
    JOIN dim_product p ON p.product_key = f.product_key
    GROUP BY p.category, p.product_key, p.product_name
)
SELECT category, product_name, total_sales,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS category_rank
FROM category_product_sales
ORDER BY category, category_rank;

-- 07. LAG: month-over-month sales change
WITH monthly AS (
    SELECT d.year, d.month,
           TO_CHAR(MAKE_DATE(d.year, d.month, 1), 'YYYY-MM') AS month,
           SUM(f.sales_amount) AS revenue
    FROM fact_sales f
    JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, d.month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
       revenue - LAG(revenue) OVER (ORDER BY year, month) AS revenue_change
FROM monthly
ORDER BY year, month;

-- 08. LEAD: next month's revenue
WITH monthly AS (
    SELECT d.year, d.month,
           TO_CHAR(MAKE_DATE(d.year, d.month, 1), 'YYYY-MM') AS month,
           SUM(f.sales_amount) AS revenue
    FROM fact_sales f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, d.month
)
SELECT month, revenue,
       LEAD(revenue) OVER (ORDER BY year, month) AS next_month_revenue
FROM monthly
ORDER BY year, month;

-- 09. NTILE: divide customers into 3 revenue segments
WITH customer_sales AS (
    SELECT c.customer_name, SUM(f.sales_amount) AS revenue
    FROM dim_customer c JOIN fact_sales f ON f.customer_key = c.customer_key
    GROUP BY c.customer_key, c.customer_name
)
SELECT customer_name, revenue,
       NTILE(3) OVER (ORDER BY revenue DESC) AS revenue_segment
FROM customer_sales
ORDER BY revenue DESC;

-- 10. Window frame: cumulative revenue
WITH monthly AS (
    SELECT d.year, d.month,
           TO_CHAR(MAKE_DATE(d.year, d.month, 1), 'YYYY-MM') AS month,
           SUM(f.sales_amount) AS revenue
    FROM fact_sales f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, d.month
)
SELECT month, revenue,
       SUM(revenue) OVER (
           ORDER BY year, month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue
FROM monthly
ORDER BY year, month;

-- 11. CTE: month-over-month growth percentage
WITH monthly AS (
    SELECT d.year, d.month,
           TO_CHAR(MAKE_DATE(d.year, d.month, 1), 'YYYY-MM') AS month,
           SUM(f.sales_amount) AS revenue
    FROM fact_sales f JOIN dim_date d ON d.date_key = f.date_key
    GROUP BY d.year, d.month
),
with_previous AS (
    SELECT *,
           LAG(revenue) OVER (ORDER BY year, month) AS previous_revenue
    FROM monthly
)
SELECT month, revenue, previous_revenue,
       ROUND(
         CASE WHEN previous_revenue IS NULL OR previous_revenue = 0
              THEN NULL
              ELSE ((revenue - previous_revenue) / previous_revenue) * 100
         END, 2
       ) AS mom_growth_pct
FROM with_previous
ORDER BY year, month;

-- 12. UNION: customers from Karnataka OR Telangana
SELECT customer_name, state FROM dim_customer WHERE state = 'Karnataka'
UNION
SELECT customer_name, state FROM dim_customer WHERE state = 'Telangana'
ORDER BY customer_name;

-- 13. INTERSECT: customers in Karnataka who purchased a product
SELECT c.customer_id FROM dim_customer c WHERE c.state = 'Karnataka'
INTERSECT
SELECT c.customer_id
FROM dim_customer c JOIN fact_sales f ON f.customer_key = c.customer_key;

-- 14. EXCEPT: customers who never purchased
SELECT customer_id FROM dim_customer
EXCEPT
SELECT c.customer_id
FROM dim_customer c JOIN fact_sales f ON f.customer_key = c.customer_key;

-- 15. ROLLUP: revenue by category/subcategory with subtotals and grand total
SELECT p.category, p.subcategory,
       SUM(f.sales_amount) AS revenue
FROM fact_sales f JOIN dim_product p ON p.product_key = f.product_key
GROUP BY ROLLUP (p.category, p.subcategory)
ORDER BY p.category NULLS LAST, p.subcategory NULLS LAST;

-- 16. CUBE: revenue across category and year dimensions
SELECT p.category, d.year,
       SUM(f.sales_amount) AS revenue
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY CUBE (p.category, d.year)
ORDER BY p.category NULLS LAST, d.year NULLS LAST;

-- 17. GROUPING SETS: selected business summaries
SELECT p.category, d.month, SUM(f.sales_amount) AS revenue
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY GROUPING SETS (
    (p.category, d.month),
    (p.category),
    (d.month),
    ()
)
ORDER BY p.category NULLS LAST, d.month NULLS LAST;

-- 18. Standard view: reusable product performance
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT p.product_id, p.product_name, p.category,
       COALESCE(SUM(f.quantity),0) AS units_sold,
       COALESCE(SUM(f.sales_amount),0) AS revenue
FROM dim_product p
LEFT JOIN fact_sales f ON f.product_key = p.product_key
GROUP BY p.product_id, p.product_name, p.category;

SELECT * FROM vw_product_performance ORDER BY revenue DESC;

-- 19. Optimization: inspect query plan
EXPLAIN ANALYZE
SELECT c.customer_name, SUM(f.sales_amount) AS revenue
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.customer_name
ORDER BY revenue DESC;

-- 20. Materialized-view style reporting layer (PostgreSQL)
DROP MATERIALIZED VIEW IF EXISTS mv_monthly_revenue;
CREATE MATERIALIZED VIEW mv_monthly_revenue AS
SELECT d.year, d.month,
       TO_CHAR(MAKE_DATE(d.year,d.month,1),'YYYY-MM') AS month,
       SUM(f.sales_amount) AS revenue
FROM fact_sales f JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year, d.month;

SELECT * FROM mv_monthly_revenue ORDER BY year, month;
