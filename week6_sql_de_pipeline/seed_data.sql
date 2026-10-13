SET search_path TO datagrokr_week6;
INSERT INTO dim_customer(customer_id,customer_name,city,state,valid_from,valid_to,is_current) VALUES
(1,'Manvith Kumar','Bengaluru','Karnataka','2025-01-01','9999-12-31',TRUE),
(2,'Asha Rao','Mysuru','Karnataka','2025-01-01','9999-12-31',TRUE),
(3,'Ravi Sharma','Hyderabad','Telangana','2025-01-01','9999-12-31',TRUE),
(4,'Neha Singh','Chennai','Tamil Nadu','2025-01-01','9999-12-31',TRUE),
(5,'Arjun Patel','Pune','Maharashtra','2025-01-01','9999-12-31',TRUE);
INSERT INTO dim_product(product_id,product_name,category,unit_price) VALUES
(101,'Laptop Pro','Electronics',75000),(102,'Wireless Mouse','Electronics',1200),
(103,'Mechanical Keyboard','Electronics',4500),(104,'Office Chair','Furniture',9000),
(105,'Monitor Stand','Furniture',2500),(106,'USB-C Hub','Electronics',3000);
INSERT INTO etl_audit(event_name,rows_affected,notes)
VALUES('SEED_DIMENSIONS',11,'Loaded initial customer and product dimensions');
