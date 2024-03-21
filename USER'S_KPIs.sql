SELECT * FROM customers
SELECT * FROM orders
SELECT * FROM order_items


-- USER REGISTRATION by MONTH - Users are registered by the First Order
WITH registration_dates AS (
	SELECT customers.customer_id,
MIN(order_date) AS registration_date
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY customers.customer_id
ORDER BY customers.customer_id ASC)

SELECT 
DATE_TRUNC('month', registration_date) :: DATE AS registration_month,
COUNT(DISTINCT customer_id) AS Registered 
FROM registration_dates 
GROUP BY registration_month
ORDER BY registration_month ASC 

--- Monthly active users 
SELECT DATE_TRUNC('month', order_date) :: DATE AS order_month, 
COUNT (DISTINCT customers.customer_id)
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY order_month 
ORDER BY order_month ASC

-- User Registrations running total 
WITH registration_dates AS (
	SELECT customers.customer_id,
MIN(order_date) AS registration_date
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY customers.customer_id),
registration AS (
SELECT DATE_TRUNC('month', registration_date) :: DATE AS order_month, 
COUNT (DISTINCT customer_id) as registered
FROM registration_dates
GROUP BY order_month) 

SELECT order_month,
SUM(registered) OVER(ORDER BY order_month) AS registered_running_total
FROM registration 
ORDER BY order_month ASC

-- Last month's Monthly active user
WITH monthly_active_user AS (
SELECT DATE_TRUNC('month', order_date) :: DATE AS order_month, 
COUNT (DISTINCT customers.customer_id) as monthly_active_users
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY order_month 
)

SELECT order_month, 
monthly_active_user,
COALESCE(LAG(monthly_active_users) OVER(ORDER BY order_month), 0) AS Last_month_monthly_active_users
FROM monthly_active_user
ORDER BY order_month ASC 


-- Monthly active user's DELTA if delta is negative there were less customers than the current month
WITH monthly_active_user AS (
SELECT DATE_TRUNC('month', order_date) :: DATE AS order_month, 
COUNT (DISTINCT customers.customer_id) as monthly_active_users
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY order_month 
),
LAST_MONTH_AU AS (
SELECT order_month, 
monthly_active_users,
COALESCE(LAG(monthly_active_users) OVER(ORDER BY order_month), 0) AS Last_month_monthly_active_users
FROM monthly_active_user)

SELECT order_month,
monthly_active_users - Last_month_monthly_active_users AS monthly_active_user_delta
FROM LAST_MONTH_AU
ORDER BY order_month ASC

-- Monthly active user's DELTA if delta is negative there were less customers than the current month
WITH monthly_active_user AS (
SELECT DATE_TRUNC('month', order_date) :: DATE AS order_month, 
COUNT (DISTINCT customers.customer_id) as monthly_active_users
FROM customers 
JOIN orders 
USING(customer_id)
GROUP BY order_month 
),
LAST_MONTH_AU AS (
SELECT order_month, 
monthly_active_users,
GREATEST(LAG(monthly_active_users) OVER(ORDER BY order_month), 1) AS Last_month_monthly_active_users
FROM monthly_active_user)

SELECT order_month,
ROUND((monthly_active_users - Last_month_monthly_active_users) :: NUMERIC / Last_month_monthly_active_users, 2)  AS monthly_active_user_delta
FROM LAST_MONTH_AU
ORDER BY order_month ASC

-- ORDERs DELTA if delta is negative there were less customers than the current month
WITH orders AS (
SELECT DATE_TRUNC('month', orders.order_date) :: DATE AS order_month, 
COUNT (DISTINCT orders.order_id) as orders
FROM orders
JOIN order_items
USING(order_id)
GROUP BY order_month 
),
LAST_MONTH_ORDERS AS (
SELECT order_month, 
orders,
COALESCE(LAG(orders) OVER(ORDER BY order_month), 1) AS Last_month_orders
FROM orders)

SELECT order_month,
ROUND((orders - Last_month_orders) :: NUMERIC / Last_month_orders, 2)  AS monthly_active_user_delta
FROM LAST_MONTH_ORDERS
ORDER BY order_month ASC

--- RETENTION RATE
WITH monthly_activity AS (
SELECT DISTINCt DATE_TRUNC('month', orders.order_date) :: DATE AS order_month, 
 orders.customer_id
FROM orders
JOIN order_items
USING(order_id))

SELECT previous.order_month, 
ROUND(
COUNT(DISTINCT current.customer_id) :: NUMERIC / 
	GREATEST(COUNT(DISTINCT previous.customer_id), 1),
	2) AS user_rentention_rate
FROM monthly_activity as previous
LEFT JOIN monthly_activity as current 
ON previous.customer_id = current.customer_id
AND previous.order_month = (current.order_month - INTERVAL '1 month')
GROUP BY previous.order_month
ORDER BY previous.order_month ASC;








