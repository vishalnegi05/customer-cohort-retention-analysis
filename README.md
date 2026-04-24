

# Customer Cohort Retention Analysis using MySQL

## Project Overview

This project analyzes customer retention using cohort analysis in MySQL.  
Customers are grouped based on their first purchase month, and their repeat purchase behavior is tracked over the following months.

The goal of this project is to understand customer loyalty, repeat purchase behavior, retention rate, and revenue contribution by cohort.

---

## Business Problem

Businesses need to know whether customers are returning after their first purchase.  
This analysis helps answer questions like:

- Which month brought the most customers?
- Which customer cohort had the highest retention?
- How many customers returned after their first purchase?
- Which cohort generated the highest revenue?
- How does customer retention change over time?

---

## Dataset

The dataset contains order-level customer transaction data.

### Table: orders

| Column Name | Description |
|---|---|
| order_id | Unique order ID |
| customer_id | Unique customer ID |
| order_date | Date of order |
| amount | Order amount |

---

## Tools Used

- MySQL
- SQL

---

## SQL Concepts Used

- GROUP BY
- Aggregate functions
- CTEs
- DATE_FORMAT()
- PERIOD_DIFF()
- CASE WHEN
- COUNT(DISTINCT)
- Conditional aggregation

---

## Key Questions Answered

1. What is the cohort month of each customer?
2. How many customers were acquired each month?
3. What is each customer's cohort month and order month?
4. How many customers returned in later months?
5. Which cohort had the highest returning customers?
6. What is the retention rate for each cohort?
7. Which cohort generated the highest revenue?
8. How can we create a cohort retention matrix?
9. How can we convert the cohort matrix into retention percentage?

---

## Analysis Summary

The analysis starts by identifying each customer's first purchase month.  
This first purchase month is treated as the customer's cohort month.

After that, customer orders are compared against their cohort month to identify repeat purchases.  
The project then calculates returned customers, retention rate, revenue by cohort, and creates a cohort matrix.

---

## Key Insights

- Customers can be grouped by their first purchase month to analyze loyalty.
- Retention can be measured by checking how many customers returned after their first purchase.
- Cohort matrix helps visualize how customer retention changes over time.
- Revenue by cohort helps identify which acquisition month brought the most valuable customers.

---

## How to Run This Project

1. Create a database in MySQL.
2. Run the table creation query from `cohort_analysis.sql`.
3. Import `dataset.csv` into the `orders` table.
4. Run the SQL queries one by one.
5. Review the output for cohort retention insights.

---

## Project Files

| File Name | Description |
|---|---|
| dataset.csv | Contains sample order transaction data |
| cohort_analysis.sql | Contains table creation and cohort analysis queries |
| README.md | Project documentation |

---

## Conclusion

This project demonstrates how SQL can be used to analyze customer retention and repeat purchase behavior.  
It is useful for understanding customer loyalty, cohort performance, and long-term revenue contribution.

---

## Author

Vishal Singh  
Aspiring Data Analyst
