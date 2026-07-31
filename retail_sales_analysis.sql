/* ----> RETAIL SALES ANALYSIS <---- */

-- Create Database 
CREATE DATABASE retail_sales_analysis;

-- Use Database
USE retail_sales_analysis;

-- Create Table
CREATE TABLE retail_sales (
    transaction_id   INT PRIMARY KEY,
    sale_date        DATE,
    customer_id      VARCHAR(20),
    gender           VARCHAR(10),
    age              INT,
    product_category VARCHAR(50),
    quantity         INT,
    price_per_unit   DECIMAL(10,2),
    total_amount     DECIMAL(12,2)
);

-- Check Data Import from Excel
SELECT * FROM retail_sales;

----------------------------------------------------------------------------
-- SECTION 1: BASIC KPI QUESTIONS
----------------------------------------------------------------------------
 
-- Q1. Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM retail_sales;
 
-- Q2. Total Transactions (Total Orders)
SELECT COUNT(transaction_id) AS total_orders
FROM retail_sales;
 
-- Q3. Average Order Value (AOV)
SELECT ROUND(SUM(total_amount) / COUNT(transaction_id), 2) AS avg_order_value
FROM retail_sales;
 
-- Q4. Total Products Sold (Total Quantity Sold)
SELECT SUM(quantity) AS total_quantity_sold
FROM retail_sales;
 
-- Q5. Average Selling Price per Product
SELECT ROUND(AVG(price_per_unit), 2) AS avg_selling_price
FROM retail_sales;
 
----------------------------------------------------------------------------
-- SECTION 2: SALES PERFORMANCE
----------------------------------------------------------------------------
 
-- Q6. Month with the Highest Revenue
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY sales_month
ORDER BY revenue DESC
LIMIT 1;
 
-- Q7. Month with the Lowest Revenue
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY sales_month
ORDER BY revenue ASC
LIMIT 1;
 
-- Q8. Monthly Sales Trend
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
       SUM(total_amount) AS revenue,
       COUNT(transaction_id) AS total_orders
FROM retail_sales
GROUP BY sales_month
ORDER BY sales_month;
 
-- Q9. Day That Recorded the Highest Sales
SELECT sale_date,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY sale_date
ORDER BY revenue DESC
LIMIT 1;
 
-- Q10. Month-over-Month (MoM) Revenue Growth  [uses LAG() window function]
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY sales_month
)
SELECT sales_month,
       revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
       ROUND(
         (revenue - LAG(revenue) OVER (ORDER BY sales_month))
         / NULLIF(LAG(revenue) OVER (ORDER BY sales_month), 0) * 100, 2
       ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY sales_month;
 
 
-- =========================================================================
-- SECTION 3: PRODUCT PERFORMANCE
-- =========================================================================
 
-- Q11. Product Category with the Highest Revenue
SELECT product_category,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY product_category
ORDER BY revenue DESC
LIMIT 1;
 
-- Q12. Product Category with the Lowest Revenue
SELECT product_category,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY product_category
ORDER BY revenue ASC
LIMIT 1;
 
-- Q13. Product Category with the Highest Quantity Sold
SELECT product_category,
       SUM(quantity) AS total_quantity
FROM retail_sales
GROUP BY product_category
ORDER BY total_quantity DESC
LIMIT 1;
 
-- Q14. Product Category with the Highest Average Selling Price
SELECT product_category,
       ROUND(AVG(price_per_unit), 2) AS avg_selling_price
FROM retail_sales
GROUP BY product_category
ORDER BY avg_selling_price DESC
LIMIT 1;
 
-- Q15. Each Product Category's Contribution (%) to Total Revenue
SELECT product_category,
       SUM(total_amount) AS category_revenue,
       ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2) AS pct_of_total_revenue
FROM retail_sales
GROUP BY product_category
ORDER BY category_revenue DESC;
 
 
----------------------------------------------------------------------------
-- SECTION 4: CUSTOMER ANALYSIS
----------------------------------------------------------------------------
 
-- Age-group bucketing used throughout this section:
--   Under 18, 18-25, 26-35, 36-45, 46-55, 56+
 
-- Q16. Age Group That Spends the Most
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    SUM(total_amount) AS total_spend
FROM retail_sales
GROUP BY age_group
ORDER BY total_spend DESC
LIMIT 1;
 
-- Q17. Gender That Contributes the Highest Revenue
SELECT gender,
       SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY gender
ORDER BY revenue DESC
LIMIT 1;
 
-- Q18. Age Group That Places the Highest Number of Orders
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(transaction_id) AS total_orders
FROM retail_sales
GROUP BY age_group
ORDER BY total_orders DESC
LIMIT 1;
 
-- Q19. Age Group That Purchases the Largest Quantity of Products
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    SUM(quantity) AS total_quantity
FROM retail_sales
GROUP BY age_group
ORDER BY total_quantity DESC
LIMIT 1;
 
-- Q20. Average Spending by Each Gender
SELECT gender,
       ROUND(AVG(total_amount), 2) AS avg_spending
FROM retail_sales
GROUP BY gender;
 
 
----------------------------------------------------------------------------
-- SECTION 5: BUSINESS INSIGHTS
----------------------------------------------------------------------------
 
-- Q21. Months Requiring Promotional Campaigns (revenue below overall monthly average)
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY sales_month
)
SELECT sales_month, revenue
FROM monthly_revenue
WHERE revenue < (SELECT AVG(revenue) FROM monthly_revenue)
ORDER BY revenue ASC;
 
-- Q22. Underperforming Product Categories (bottom by revenue AND quantity)
SELECT product_category,
       SUM(total_amount) AS revenue,
       SUM(quantity) AS quantity_sold,
       RANK() OVER (ORDER BY SUM(total_amount) ASC) AS revenue_rank_lowest,
       RANK() OVER (ORDER BY SUM(quantity) ASC) AS quantity_rank_lowest
FROM retail_sales
GROUP BY product_category
ORDER BY revenue ASC;
 
-- Q23. Best Customer Segment to Target (age group + gender combo with highest revenue)
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    gender,
    SUM(total_amount) AS revenue
FROM retail_sales
GROUP BY age_group, gender
ORDER BY revenue DESC
LIMIT 1;
 
-- Q24. Product Categories That Should Receive More Inventory
-- (high demand = top categories by BOTH quantity sold and revenue)
SELECT product_category,
       SUM(quantity) AS quantity_sold,
       SUM(total_amount) AS revenue,
       RANK() OVER (ORDER BY SUM(quantity) DESC) AS quantity_rank,
       RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM retail_sales
GROUP BY product_category
ORDER BY quantity_rank, revenue_rank;
 
-- Q25. Top 5 Business Insights - single summary query
-- (best month, best category, highest-spending age group, top gender, top revenue category)
-- in parentheses when combined with UNION.
(SELECT 'Best Performing Month' AS insight,
        DATE_FORMAT(sale_date, '%Y-%m') AS detail,
        SUM(total_amount) AS value
 FROM retail_sales
 GROUP BY detail
 ORDER BY value DESC LIMIT 1)
 
UNION ALL
 
(SELECT 'Best Selling Category (by Quantity)',
        product_category,
        SUM(quantity)
 FROM retail_sales
 GROUP BY product_category
 ORDER BY 3 DESC LIMIT 1)
 
UNION ALL
 
(SELECT 'Highest Spending Age Group',
        CASE
            WHEN age < 18 THEN 'Under 18'
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+'
        END,
        SUM(total_amount)
 FROM retail_sales
 GROUP BY 2
 ORDER BY 3 DESC LIMIT 1)
 
UNION ALL
 
(SELECT 'Gender with Highest Revenue',
        gender,
        SUM(total_amount)
 FROM retail_sales
 GROUP BY gender
 ORDER BY 3 DESC LIMIT 1)
 
UNION ALL
 
(SELECT 'Top Revenue Product Category',
        product_category,
        SUM(total_amount)
 FROM retail_sales
 GROUP BY product_category
 ORDER BY 3 DESC LIMIT 1);


-- 26. Running Total of Monthly Revenue
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY sales_month
)
SELECT sales_month,
       revenue,
       SUM(revenue) OVER (ORDER BY sales_month
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue
FROM monthly_revenue
ORDER BY sales_month;
 
-- 27. Rank Product Categories by Revenue (RANK vs DENSE_RANK)
SELECT product_category,
       SUM(total_amount) AS revenue,
       RANK()       OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank,
       DENSE_RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_dense_rank
FROM retail_sales
GROUP BY product_category
ORDER BY revenue DESC;
 
-- 28. Pareto Analysis - categories contributing to the top ~80% of revenue
WITH category_revenue AS (
    SELECT product_category,
           SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY product_category
),
ranked AS (
    SELECT product_category,
           revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC
                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
           SUM(revenue) OVER () AS total_revenue
    FROM category_revenue
)
SELECT product_category,
       revenue,
       ROUND(cumulative_revenue * 100.0 / total_revenue, 2) AS cumulative_pct
FROM ranked
ORDER BY revenue DESC;
-- Categories appearing before cumulative_pct crosses 80% are the "vital few" (Pareto principle).
 
-- 29. Compare Each Month's Revenue with the Previous Month (LAG)
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(total_amount) AS revenue
    FROM retail_sales
    GROUP BY sales_month
)
SELECT sales_month,
       revenue,
       LAG(revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
       revenue - LAG(revenue) OVER (ORDER BY sales_month) AS revenue_change
FROM monthly_revenue
ORDER BY sales_month;
 
-- 30. Categorize Customers into High / Medium / Low Spenders (CASE)
WITH customer_spend AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM retail_sales
    GROUP BY customer_id
)
SELECT customer_id,
       total_spent,
       CASE
           WHEN total_spent >= 1000 THEN 'High Spender'
           WHEN total_spent >= 400  THEN 'Medium Spender'
           ELSE 'Low Spender'
       END AS spender_segment
FROM customer_spend
ORDER BY total_spent DESC;
 
-- Age-group version, categorized directly by average spend per group
SELECT age_group,
       avg_spend,
       CASE
           WHEN avg_spend >= 1000 THEN 'High'
           WHEN avg_spend >= 400  THEN 'Medium'
           ELSE 'Low'
       END AS spender_category
FROM (
    SELECT
        CASE
            WHEN age < 18 THEN 'Under 18'
            WHEN age BETWEEN 18 AND 25 THEN '18-25'
            WHEN age BETWEEN 26 AND 35 THEN '26-35'
            WHEN age BETWEEN 36 AND 45 THEN '36-45'
            WHEN age BETWEEN 46 AND 55 THEN '46-55'
            ELSE '56+'
        END AS age_group,
        AVG(total_amount) AS avg_spend
    FROM retail_sales
    GROUP BY age_group
) t
ORDER BY avg_spend DESC;
 