-- Week 5 seed data
SET search_path TO datagrokr_week5;

INSERT INTO dim_customer (customer_id, customer_name, city, state, country) VALUES
(1,'Manvith Kumar','Bengaluru','Karnataka','India'),
(2,'Asha Rao','Mysuru','Karnataka','India'),
(3,'Ravi Sharma','Hyderabad','Telangana','India'),
(4,'Neha Singh','Chennai','Tamil Nadu','India'),
(5,'Arjun Patel','Pune','Maharashtra','India');

INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
(101,'Laptop Pro','Electronics','Computers',75000),
(102,'Wireless Mouse','Electronics','Accessories',1200),
(103,'Mechanical Keyboard','Electronics','Accessories',4500),
(104,'Office Chair','Furniture','Chairs',9000),
(105,'Monitor Stand','Furniture','Accessories',2500),
(106,'USB-C Hub','Electronics','Accessories',3000);

INSERT INTO dim_date (date_key, full_date, year, quarter, month, month_name) VALUES
(20260105,'2026-01-05',2026,1,1,'January'),
(20260112,'2026-01-12',2026,1,1,'January'),
(20260120,'2026-01-20',2026,1,1,'January'),
(20260203,'2026-02-03',2026,1,2,'February'),
(20260214,'2026-02-14',2026,1,2,'February'),
(20260228,'2026-02-28',2026,1,2,'February'),
(20260302,'2026-03-02',2026,1,3,'March'),
(20260315,'2026-03-15',2026,1,3,'March'),
(20260322,'2026-03-22',2026,1,3,'March'),
(20260405,'2026-04-05',2026,2,4,'April'),
(20260418,'2026-04-18',2026,2,4,'April'),
(20260425,'2026-04-25',2026,2,4,'April');

INSERT INTO fact_sales (order_id, date_key, customer_key, product_key, quantity, sales_amount)
SELECT 1001,20260105,1,101,1,75000
UNION ALL SELECT 1002,20260112,2,102,2,2400
UNION ALL SELECT 1003,20260120,3,104,1,9000
UNION ALL SELECT 1004,20260203,1,103,1,4500
UNION ALL SELECT 1005,20260214,4,106,2,6000
UNION ALL SELECT 1006,20260228,5,101,1,75000
UNION ALL SELECT 1007,20260302,2,104,2,18000
UNION ALL SELECT 1008,20260315,3,102,3,3600
UNION ALL SELECT 1009,20260322,1,106,1,3000
UNION ALL SELECT 1010,20260405,4,101,1,75000
UNION ALL SELECT 1011,20260418,5,103,2,9000
UNION ALL SELECT 1012,20260425,2,102,4,4800;
