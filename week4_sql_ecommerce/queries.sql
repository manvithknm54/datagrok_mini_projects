-- Week 4 Mini Project — Analysis Queries
-- Run after schema.sql and seed_data.sql

-- ============================================================
-- Query 1: Top Products by Revenue
-- Which products generated the most revenue (price * quantity)?
-- ============================================================
SELECT
    products.name AS product_name,
    products.category,
    SUM(orders.quantity) AS total_units_sold,
    SUM(products.price * orders.quantity) AS total_revenue
FROM orders
JOIN products ON orders.product_id = products.id
GROUP BY products.id, products.name, products.category
ORDER BY total_revenue DESC;


-- ============================================================
-- Query 2: Customer Spend
-- Total amount spent per customer — including customers with
-- ZERO orders (shown as 0, not dropped), using LEFT JOIN + COALESCE
-- ============================================================
SELECT
    customers.name AS customer_name,
    customers.city,
    COALESCE(SUM(products.price * orders.quantity), 0) AS total_spent
FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id
LEFT JOIN products ON orders.product_id = products.id
GROUP BY customers.id, customers.name, customers.city
ORDER BY total_spent DESC;


-- ============================================================
-- Query 3: Order Trends by Month
-- How many orders and how much revenue per month?
-- ============================================================
SELECT
    strftime('%Y-%m', orders.order_date) AS order_month,
    COUNT(*) AS order_count,
    SUM(products.price * orders.quantity) AS monthly_revenue
FROM orders
JOIN products ON orders.product_id = products.id
GROUP BY order_month
ORDER BY order_month;


-- ============================================================
-- Query 4: Products Never Ordered
-- Products with no matching order at all — LEFT JOIN + IS NULL
-- ============================================================
SELECT products.name, products.category
FROM products
LEFT JOIN orders ON products.id = orders.product_id
WHERE orders.id IS NULL;


-- ============================================================
-- Query 5: Customers Who Never Ordered
-- Same LEFT JOIN + IS NULL pattern, applied to customers instead
-- ============================================================
SELECT customers.name, customers.city
FROM customers
LEFT JOIN orders ON customers.id = orders.customer_id
WHERE orders.id IS NULL;
