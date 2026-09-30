# Week 4 Mini Project — E-commerce Database

**Track:** SQL (Week 4 — Beginner)
**Program:** DataGrokr Pre-Learning Program (PLP)

## Description

A 3-table e-commerce database (`customers`, `products`, `orders`) with 5 analysis queries covering Week 4's core fundamentals: **JOINs, GROUP BY, aggregates, NULL handling, and date functions.**

## Files

```
week4_sql_ecommerce/
├── schema.sql       # CREATE TABLE statements with constraints
├── seed_data.sql     # sample rows to populate the database
├── queries.sql        # the 5 required analysis queries
└── README.md
```

## Schema Design Notes

- `customers.id`, `products.id`, `orders.id` are `PRIMARY KEY` — enforces uniqueness automatically.
- `orders.customer_id` and `orders.product_id` are `FOREIGN KEY` references — the database rejects any order that points to a customer or product that doesn't actually exist, catching bad data at the source rather than letting it corrupt reports later.
- `CHECK (price > 0)` and `CHECK (quantity > 0)` constraints prevent nonsensical values (a negative price or a zero-quantity order) from ever being inserted.
- Seed data **deliberately includes edge cases**: one customer (Manvith Kumar) with zero orders, and one product (Monitor Stand) that's never been ordered — specifically to prove the LEFT JOIN queries handle "no match" correctly instead of just working on the easy cases.

## The 5 Queries (`queries.sql`)

1. **Top Products by Revenue** — `JOIN` + `GROUP BY` + `SUM`, sorted by total revenue descending.
2. **Customer Spend** — `LEFT JOIN` (not INNER) so customers with zero orders still appear, with `COALESCE` turning their `NULL` total into `0` instead of showing nothing.
3. **Order Trends by Month** — groups orders by month using `strftime('%Y-%m', order_date)`, showing order count and revenue per month.
4. **Products Never Ordered** — `LEFT JOIN` from products to orders, filtered with `WHERE orders.id IS NULL` — the classic "find unmatched records" pattern.
5. **Customers Who Never Ordered** — same LEFT JOIN + IS NULL pattern, applied the other direction.

**Why LEFT JOIN matters for queries 2, 4, and 5 specifically:** an `INNER JOIN` would silently drop any customer or product with no matching orders — which is exactly the kind of data a real business would want to see ("which customers haven't ordered yet, so we can follow up?"). Using LEFT JOIN + `IS NULL`/`COALESCE` is a deliberate choice to surface the "nothing happened here" case instead of hiding it.

## How to Run

Using SQLite (no server setup needed):
```bash
sqlite3 ecommerce.db < schema.sql
sqlite3 ecommerce.db < seed_data.sql
sqlite3 ecommerce.db < queries.sql
```

Or in Python:
```python
import sqlite3
conn = sqlite3.connect("ecommerce.db")
conn.executescript(open("schema.sql").read())
conn.executescript(open("seed_data.sql").read())
# then run individual queries from queries.sql as needed
```

## Verified Output

**Query 1 — Top Products by Revenue:**
```
product_name    | category    | total_units_sold | total_revenue
Laptop          | Electronics | 3                 | 165000
Office Desk     | Furniture   | 1                 | 8000
Desk Chair      | Furniture   | 1                 | 6000
Keyboard        | Electronics | 5                 | 6000
Wireless Mouse  | Electronics | 7                 | 3500
```

**Query 2 — Customer Spend (note Manvith Kumar correctly shows 0, not dropped):**
```
customer_name    | city      | total_spent
Priya Menon      | Bangalore | 60600
Asha Rao         | Bangalore | 58400
Divya Iyer       | Mumbai    | 55000
Ravi Kumar       | Mumbai    | 8500
Kiran Shetty     | Chennai   | 6000
Manvith Kumar    | Mysuru    | 0
```

**Query 3 — Order Trends by Month:**
```
order_month | order_count | monthly_revenue
2024-05     | 4           | 119000
2024-06     | 3           | 10100
2024-07     | 3           | 59400
```

**Query 4 — Products Never Ordered:**
```
name           | category
Monitor Stand  | Furniture
```

**Query 5 — Customers Who Never Ordered:**
```
name            | city
Manvith Kumar   | Mysuru
```

## Author

Manvith — DataGrokr PLP, Week 4
