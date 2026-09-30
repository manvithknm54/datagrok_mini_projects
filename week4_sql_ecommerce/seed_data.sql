-- Week 4 Mini Project — Seed Data
-- Run after schema.sql

INSERT INTO customers (id, name, city, signup_date) VALUES
(1, 'Asha Rao', 'Bangalore', '2024-01-15'),
(2, 'Ravi Kumar', 'Mumbai', '2024-02-20'),
(3, 'Priya Menon', 'Bangalore', '2024-03-10'),
(4, 'Kiran Shetty', 'Chennai', '2024-04-05'),
(5, 'Divya Iyer', 'Mumbai', '2024-05-18'),
(6, 'Manvith Kumar', 'Mysuru', '2024-06-01');
-- Note: customer 6 deliberately has NO orders, to test LEFT JOIN behavior

INSERT INTO products (id, name, category, price) VALUES
(1, 'Laptop', 'Electronics', 55000),
(2, 'Wireless Mouse', 'Electronics', 500),
(3, 'Office Desk', 'Furniture', 8000),
(4, 'Desk Chair', 'Furniture', 6000),
(5, 'Keyboard', 'Electronics', 1200),
(6, 'Monitor Stand', 'Furniture', 900);
-- Note: product 6 (Monitor Stand) deliberately has NO orders, to test "never ordered" query

INSERT INTO orders (id, customer_id, product_id, quantity, order_date) VALUES
(1, 1, 1, 1, '2024-05-01'),
(2, 1, 2, 2, '2024-05-01'),
(3, 2, 3, 1, '2024-05-15'),
(4, 3, 1, 1, '2024-05-20'),
(5, 3, 5, 3, '2024-06-02'),
(6, 4, 4, 1, '2024-06-10'),
(7, 2, 2, 1, '2024-06-15'),
(8, 1, 5, 2, '2024-07-01'),
(9, 5, 1, 1, '2024-07-05'),
(10, 3, 2, 4, '2024-07-10');
