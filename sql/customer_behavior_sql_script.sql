CREATE DATABASE customer_behavior;
SHOW DATABASES;

SELECT * FROM customer
LIMIT 5;

/* ==========================================================
   Customer Revenue Analysis
   Compare Revenue Contribution by Gender
   ========================================================== */

SELECT
    gender,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount)
        / SUM(SUM(purchase_amount)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

/* ==========================================================
   Discount Effectiveness Analysis
   Identify Customers Who Used Discounts but Spent Above Average
   ========================================================== */

SELECT
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
        SELECT AVG(purchase_amount)
        FROM customer
      )
ORDER BY purchase_amount DESC;


/* ==========================================================
   Product Rating Analysis
   Identify the Top 5 Highest-Rated Products
   ========================================================== */

SELECT
    item_purchased,
    ROUND(AVG(review_rating), 2) AS average_product_rating,
    COUNT(*) AS total_reviews
FROM customer
GROUP BY item_purchased
ORDER BY average_product_rating DESC
LIMIT 5;

/* ==========================================================
   Shipping Preference Analysis
   Compare Average Purchase Amount Between Standard and Express Shipping
   ========================================================== */

SELECT
    shipping_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount,
    ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY avg_purchase_amount DESC;


/* ==========================================================
   Subscription Performance Analysis
   Analyze Customer Spending and Revenue Contribution by Subscription Status
   ========================================================== */

SELECT
    subscription_status,
    COUNT(*) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS avg_purchase_amount,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount)
        / SUM(SUM(purchase_amount)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;

/* ==========================================================
   Discount Utilization Analysis
   Identify the Top 5 Products with the Highest Discount Purchase Rate
   ========================================================== */

SELECT
    item_purchased,
    COUNT(*) AS total_purchases,
    SUM(
        CASE
            WHEN discount_applied = 'Yes' THEN 1
            ELSE 0
        END
    ) AS discounted_purchases,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS discount_purchase_rate_pct
FROM customer
GROUP BY item_purchased
ORDER BY discount_purchase_rate_pct DESC
LIMIT 5;


/* ==========================================================
   Customer Loyalty Segmentation Analysis
   ========================================================== */

WITH customer_segments AS (
    SELECT
        customer_id,
        CASE
            WHEN previous_purchases = 1 THEN 'New Customer'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning Customer'
            ELSE 'Loyal Customer'
        END AS customer_segment
    FROM customer
)

SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;

/* ==========================================================
   Product Performance Analysis
   Identify the Top 3 Most Purchased Products Within Each Category
   ========================================================== */

WITH product_rankings AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS product_rank
    FROM customer
    GROUP BY
        category,
        item_purchased
)

SELECT
    category,
    product_rank,
    item_purchased,
    total_orders
FROM product_rankings
WHERE product_rank <= 3
ORDER BY
    category,
    product_rank;
    
/* ==========================================================
   Customer Retention Analysis
   Analyze Subscription Status Among Repeat Buyers
   ========================================================== */

SELECT
    subscription_status,
    COUNT(customer_id) AS repeat_buyers,
    ROUND(
        100.0 * COUNT(customer_id) / SUM(COUNT(customer_id)) OVER (),
        2
    ) AS percentage_of_repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status
ORDER BY repeat_buyers DESC;

/* ==========================================================
   Revenue Contribution Analysis
   Analyze Revenue Contribution by Age Group
   ========================================================== */

SELECT
    age_group,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount)
        / SUM(SUM(purchase_amount)) OVER (),
        2
    ) AS revenue_contribution_pct
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;