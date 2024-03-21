SELECT * FROM order_items 
SELECT * FROM customers 
SELECT * FROM orders

--- Average revenue Per user
WITH revenue_per_user AS(
SELECT customers.customer_id,
ROUND(SUM(order_items.list_price * order_items.quantity)) AS ORIGINAL_PRICE,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT ROUND(AVG(REVENUE) :: NUMERIC, 2)
FROM revenue_per_user

-- Average Revenue Per Customers Per week 
WITH weekly_revenue_per_user AS (
SELECT DATE_TRUNC('week', order_date) AS weekly,
ROUND(SUM(order_items.list_price * order_items.quantity)) AS ORIGINAL_PRICE,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE,
COUNT(DISTINCT customers.customer_id) AS customers
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY weekly
)
SELECT 
weekly, 
ROUND(REVENUE :: NUMERIC/ GREATEST(customers, 1)) AS Weekly_Avg_revenue_Per_user
FROM weekly_revenue_per_user
ORDER BY weekly ASC

-- Average orders per Customers
WITH average_orders_per_customers AS (
SELECT COUNT(DISTINCT customers.customer_id) AS customers,
	COUNT(DISTINCT order_items.order_id) AS orders
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)	
)
SELECT 
ROUND( 
orders :: NUMERIC / GREATEST(customers, 1) ) AS average_orders_per_customers
FROM average_orders_per_customers

-- FREQUENCY Tables of Revenue
WITH revenue_by_customer AS (SELECT customers.customer_id,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT COUNT(DISTINCT customer_id) AS customers, 
ROUND(Revenue :: NUMERIC, -2) AS revenue_hundreds
FROM revenue_by_customer
GROUP BY revenue_hundreds 
ORDER BY revenue_hundreds ASC

-- FREQUENCY TABLE Of Orders
WITH orders AS (SELECT customers.customer_id,
COUNT(DISTINCT order_items.order_id) AS orders 
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT orders,
COUNT(DISTINCT customer_id) as customers
FROM orders 
GROUP BY orders
ORDER BY orders ASC

-- Bucketing customers based on their revenue 
WITH revenue AS(
SELECT customers.customer_id,
ROUND(SUM(order_items.list_price * order_items.quantity)) AS ORIGINAL_PRICE,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT 
CASE WHEN REVENUE < 1000 THEN 'Low-revenue customers'
WHEN REVENUE < 7000 THEN 'Mid-revenue customers'
ELSE 'High-revenue customers' END AS revenue_segments,
COUNT(DISTINCT customer_id) AS customers 
FROM revenue
group by revenue_segments


-- Bucketing customers based on their order count 
WITH users_order AS(
SELECT customers.customer_id,
COUNT(DISTINCT order_items.order_id) AS orders 
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT 
CASE WHEN orders < 2 THEN 'Low-orders customers'
WHEN orders < 3 THEN 'Mid-orders customers'
ELSE 'High-orders customers' END AS orders_segments,
COUNT(DISTINCT customer_id) AS customers 
FROM users_order
group by orders_segments

--- Revenue quartiles 
WITH revenues AS(
SELECT customers.customer_id,
ROUND(SUM(order_items.list_price * order_items.quantity)) AS ORIGINAL_PRICE,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id)

SELECT

  ROUND(
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY REVENUE ASC) :: NUMERIC,
  2) AS revenue_p25,
  ROUND(
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY REVENUE ASC) :: NUMERIC ,
  2) AS revenue_p50,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY REVENUE ASC) :: NUMERIC ,
  2) AS revenue_p75,
  ROUND(AVG(REVENUE) :: NUMERIC, 2) AS avg_revenue
FROM revenues;


--- inter quartile range 
WITH revenues AS(
SELECT customers.customer_id,
ROUND(SUM(order_items.list_price * order_items.quantity)) AS ORIGINAL_PRICE,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM order_items
JOIN orders
USING(order_id)
JOIN customers
USING(customer_id)
GROUP BY customers.customer_id),

quartiles AS (SELECT
	ROUND(
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY REVENUE ASC) :: NUMERIC,
  2) AS revenue_p25,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY REVENUE ASC) :: NUMERIC ,
  2) AS revenue_p75
FROM revenues)

SELECT
  COUNT(DISTINCT customer_id) AS customers
FROM revenues
CROSS JOIN quartiles
WHERE revenue :: NUMERIC >= revenue_p25
  AND revenue:: NUMERIC <= revenue_p75;



