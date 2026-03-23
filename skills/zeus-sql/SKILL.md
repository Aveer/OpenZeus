---
name: zeus-sql
description: SQL reference for database queries, schema design, and common patterns for SQLite, PostgreSQL, MySQL, and common ORMs.
---

# zeus-sql (Skill)

Purpose: SQL reference for database queries, schema design, and common patterns for SQLite, PostgreSQL, MySQL, and common ORMs.

---

## Quick Reference - Common Queries

### Select with Filtering
```sql
SELECT * FROM users WHERE id = 1;
SELECT * FROM orders WHERE status = 'pending' AND created_at > '2024-01-01';
SELECT * FROM products WHERE price BETWEEN 10 AND 50;
```

### Joins
```sql
-- Inner join
SELECT o.id, u.name FROM orders o INNER JOIN users u ON o.user_id = u.id;

-- Left join (include NULLs from left table)
SELECT u.name, o.id FROM users u LEFT JOIN orders o ON u.id = o.user_id;

-- Multiple joins
SELECT o.id, u.name, p.name as product
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

### Aggregations
```sql
-- Count, Sum, Avg, Min, Max
SELECT COUNT(*), SUM(amount), AVG(price), MIN(created_at), MAX(updated_at)
FROM orders;

-- Group by with having
SELECT user_id, COUNT(*) as order_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 5;
```

### Insert, Update, Delete
```sql
INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com');
INSERT INTO users (name, email) VALUES 
  ('Bob', 'bob@example.com'),
  ('Charlie', 'charlie@example.com');

UPDATE users SET name = 'Alice Smith' WHERE id = 1;
UPDATE products SET price = price * 0.9 WHERE category = 'sale';

DELETE FROM sessions WHERE expires_at < NOW();
```

### Upsert (Insert or Update)
```sql
-- PostgreSQL
INSERT INTO users (id, name, email) VALUES (1, 'Alice', 'alice@test.com')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- SQLite 3.24+
INSERT INTO users (id, name, email) VALUES (1, 'Alice', 'alice@test.com')
ON CONFLICT(id) DO UPDATE SET name = EXCLUDED.name;

-- MySQL (REPLACE or ON DUPLICATE KEY)
INSERT INTO users (id, name, email) VALUES (1, 'Alice', 'alice@test.com')
ON DUPLICATE KEY UPDATE name = VALUES(name);
```

---

## Schema Design Patterns

### Common Tables
```sql
-- Users table
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders with foreign keys
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id),
  status TEXT DEFAULT 'pending',
  total DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Join table for many-to-many
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER DEFAULT 1,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE(order_id, product_id)
);
```

### Indexes
```sql
-- Single column index
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- Composite index (for queries filtering on multiple columns)
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Partial index (PostgreSQL)
CREATE INDEX idx_orders_pending ON orders(user_id) WHERE status = 'pending';
```

---

## Common ORM Patterns

### SQLAlchemy (Python)
```python
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.orm import sessionmaker
from datetime import datetime

engine = create_engine('sqlite:///app.db')
Session = sessionmaker(bind=engine)
session = Session()

# Query
user = session.query(User).filter(User.email == 'test@example.com').first()

# Insert
new_user = User(username='alice', email='alice@test.com')
session.add(new_user)
session.commit()

# Update
user = session.query(User).filter(User.id == 1).first()
user.name = 'Alice Smith'
session.commit()

# Delete
session.query(User).filter(User.id == 1).delete()
session.commit()
```

### Prisma (Node.js)
```typescript
const user = await prisma.user.findUnique({
  where: { email: 'test@example.com' }
});

const orders = await prisma.order.findMany({
  where: { userId: 1 },
  include: { items: true }
});

const newUser = await prisma.user.create({
  data: { username: 'alice', email: 'alice@test.com' }
});
```

### Drizzle (Node.js)
```typescript
import { users, orders } from './schema';

const user = await db.select().from(users).where(eq(users.email, 'test@example.com'));
```

---

## Window Functions

### Rownumber, Rank, Dense Rank
```sql
-- Rank users by order count
SELECT 
  user_id,
  COUNT(*) as order_count,
  RANK() OVER (ORDER BY COUNT(*) DESC) as rank,
  DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as dense_rank
FROM orders
GROUP BY user_id;
```

### Partition by (grouped ranking)
```sql
-- Rank products within each category
SELECT 
  name,
  category,
  price,
  RANK() OVER (PARTITION BY category ORDER BY price DESC) as rank_in_category
FROM products;
```

### Running Total
```sql
SELECT 
  id,
  amount,
  SUM(amount) OVER (ORDER BY id) as running_total
FROM transactions;
```

---

## Common SQLite Commands

```bash
# Open database
sqlite3 app.db

# List tables
.tables

# Show schema
.schema users

# Show all indexes
.indexes

# Export to SQL
.dump

# Import SQL file
.read schema.sql

# Query from command line
sqlite3 app.db "SELECT * FROM users LIMIT 5;"
```

---

## PostgreSQL Specific

```sql
-- Insert returning
INSERT INTO users (name) VALUES ('Alice') RETURNING id, *;

-- JSON operations
SELECT data->>'field' FROM table;
SELECT json_build_object('key', value);
SELECT * FROM json_each('{"a":1, "b":2}');

-- Array operations
SELECT ARRAY[1,2,3] @> ARRAY[1];  -- contains
SELECT ARRAY[1,2] || ARRAY[3];    -- concatenation

-- CTEs (Common Table Expressions)
WITH recent_orders AS (
  SELECT * FROM orders WHERE created_at > '2024-01-01'
)
SELECT u.name, ro.count
FROM users u
JOIN (SELECT user_id, COUNT(*) as count FROM recent_orders GROUP BY user_id) ro
ON u.id = ro.user_id;
```

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Slow queries | Use EXPLAIN ANALYZE; add indexes |
| Lock contention | Use transactions, avoid long-held locks |
| N+1 queries | Use JOIN, eager loading (include/joinedload) |
| NULL comparison | Use `IS NULL` or `IS NOT NULL`, not `= NULL` |
| String comparison | Use `ILIKE` for case-insensitive (PostgreSQL) |

---

## Migration Patterns

### Add Column
```sql
ALTER TABLE users ADD COLUMN phone TEXT;
```

### Rename Table
```sql
ALTER TABLE orders RENAME TO orders_new;
```

### Drop Column (PostgreSQL)
```sql
ALTER TABLE users DROP COLUMN old_field;
```

---

End of skill.