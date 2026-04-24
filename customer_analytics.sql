
CREATE DATABASE IF NOT EXISTS customer_analytics_db;
USE customer_analytics_db;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount INT
);
-- =========================================
-- PROJECT: CUSTOMER COHORT ANALYSIS
-- DATABASE: customer_analytics_db
-- =========================================


-- ==============================
-- Question 1:
-- Find cohort month (first purchase month) of each customer
-- ==============================

SELECT 
    customer_id,
    DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
FROM orders
GROUP BY customer_id;



-- ==============================
-- Question 2:
-- How many customers were acquired each month?
-- ==============================

SELECT 
    DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month,
    COUNT(customer_id) AS total_customers
FROM orders
GROUP BY customer_id
-- Wrap above query as subquery to count properly
;


SELECT 
    cohort_month,
    COUNT(*) AS total_customers
FROM (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
) t
GROUP BY cohort_month
ORDER BY cohort_month;



-- ==============================
-- Question 3:
-- Show each customer’s cohort month and order month
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT 
    o.customer_id,
    cc.cohort_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month
FROM orders o
JOIN customer_cohort cc
    ON o.customer_id = cc.customer_id
ORDER BY o.customer_id, order_month;



-- ==============================
-- Question 4:
-- How many customers returned in each month (excluding first purchase)?
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT 
    cc.cohort_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.customer_id) AS returned_customers
FROM orders o
JOIN customer_cohort cc
    ON o.customer_id = cc.customer_id
WHERE DATE_FORMAT(o.order_date, '%Y-%m') > cc.cohort_month
GROUP BY cc.cohort_month, order_month
ORDER BY cc.cohort_month, order_month;



-- ==============================
-- Question 5:
-- Which cohort has highest returning customers?
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT 
    cc.cohort_month,
    COUNT(DISTINCT o.customer_id) AS returned_customers
FROM orders o
JOIN customer_cohort cc
    ON o.customer_id = cc.customer_id
WHERE DATE_FORMAT(o.order_date, '%Y-%m') > cc.cohort_month
GROUP BY cc.cohort_month
ORDER BY returned_customers DESC;



-- ==============================
-- Question 6:
-- Retention Rate (%) per cohort
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
),
total_customers AS (
    SELECT 
        cohort_month,
        COUNT(*) AS total_customers
    FROM customer_cohort
    GROUP BY cohort_month
),
returned_customers AS (
    SELECT 
        cc.cohort_month,
        COUNT(DISTINCT o.customer_id) AS returned_customers
    FROM orders o
    JOIN customer_cohort cc
        ON o.customer_id = cc.customer_id
    WHERE DATE_FORMAT(o.order_date, '%Y-%m') > cc.cohort_month
    GROUP BY cc.cohort_month
)
SELECT 
    t.cohort_month,
    t.total_customers,
    r.returned_customers,
    ROUND((r.returned_customers * 100.0) / t.total_customers, 2) AS retention_rate
FROM total_customers t
LEFT JOIN returned_customers r
    ON t.cohort_month = r.cohort_month
ORDER BY retention_rate DESC;



-- ==============================
-- Question 7:
-- Which cohort generated highest revenue?
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month
    FROM orders
    GROUP BY customer_id
)
SELECT 
    cc.cohort_month,
    SUM(o.amount) AS total_revenue
FROM orders o
JOIN customer_cohort cc
    ON o.customer_id = cc.customer_id
GROUP BY cc.cohort_month
ORDER BY total_revenue DESC;



-- ==============================
-- Question 8:
-- Create Cohort Matrix (Retention Table)
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order
    FROM orders
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        DATE_FORMAT(cc.first_order, "%Y-%m") AS cohort_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, "%Y%m"),
            DATE_FORMAT(cc.first_order, "%Y%m")
        ) AS month_number
    FROM orders o
    JOIN customer_cohort cc
        ON o.customer_id = cc.customer_id
),
cohort_count AS (
    SELECT 
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS customers
    FROM cohort_data
    GROUP BY cohort_month, month_number
)
SELECT 
    cohort_month,
    SUM(CASE WHEN month_number = 0 THEN customers ELSE 0 END) AS month_0,
    SUM(CASE WHEN month_number = 1 THEN customers ELSE 0 END) AS month_1,
    SUM(CASE WHEN month_number = 2 THEN customers ELSE 0 END) AS month_2,
    SUM(CASE WHEN month_number = 3 THEN customers ELSE 0 END) AS month_3
FROM cohort_count
GROUP BY cohort_month
ORDER BY cohort_month;



-- ==============================
-- Question 9:
-- Convert Cohort Matrix into Retention %
-- ==============================

WITH customer_cohort AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order
    FROM orders
    GROUP BY customer_id
),
cohort_data AS (
    SELECT 
        o.customer_id,
        DATE_FORMAT(cc.first_order, "%Y-%m") AS cohort_month,
        PERIOD_DIFF(
            DATE_FORMAT(o.order_date, "%Y%m"),
            DATE_FORMAT(cc.first_order, "%Y%m")
        ) AS month_number
    FROM orders o
    JOIN customer_cohort cc
        ON o.customer_id = cc.customer_id
),
cohort_count AS (
    SELECT 
        cohort_month,
        month_number,
        COUNT(DISTINCT customer_id) AS customers
    FROM cohort_data
    GROUP BY cohort_month, month_number
),
cohort_matrix AS (
    SELECT 
        cohort_month,
        SUM(CASE WHEN month_number = 0 THEN customers ELSE 0 END) AS month_0,
        SUM(CASE WHEN month_number = 1 THEN customers ELSE 0 END) AS month_1,
        SUM(CASE WHEN month_number = 2 THEN customers ELSE 0 END) AS month_2,
        SUM(CASE WHEN month_number = 3 THEN customers ELSE 0 END) AS month_3
    FROM cohort_count
    GROUP BY cohort_month
)
SELECT 
    cohort_month,
    100 AS month_0,
    ROUND((month_1 * 100.0) / month_0, 2) AS month_1,
    ROUND((month_2 * 100.0) / month_0, 2) AS month_2,
    ROUND((month_3 * 100.0) / month_0, 2) AS month_3
FROM cohort_matrix
ORDER BY cohort_month;
                