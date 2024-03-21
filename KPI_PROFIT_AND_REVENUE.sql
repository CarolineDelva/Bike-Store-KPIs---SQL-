--- Calculating revenue 
SELECT * FROM customers

SELECT * FROM orders

SELECT * FROM order_items

SELECT * FROM stocks

SELECT * FROM products

SELECT * FROM staffs

SELECT * FROM stores

SELECT RANDOM()

ALTER TABLE products 
ADD COLUMN product_cost FLOAT  

ALTEr TABLE products 
DROP COLUMN product_cost

UPDATE products SET product_cost = RANDOM() *1000.00
WHERE product_cost IS NULL

ALTER TABLE stocks 
DROP COLUMN stocking_date  

ALTER TABLE stocks 
ADD COLUMN stocking_date Date 

UPDATE stocks SET stocking_date = timestamp '2016-01-10 20:00:00' +
       random() * (timestamp '2016-01-20 20:00:00' -
                   timestamp '2018-01-10 10:00:00')
WHERE stocking_date IS NULL


--- REVENUE FROM CUSTOMER 1296
SELECT
customers.firstname,
customers.lastname,
ROUND(SUM(order_items.quantity * order_items.list_price)) AS ORIGINAL_PRICE,
ROUND(SUM(1-order_items.discount) AS DISCOUNT,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM customers 
JOIN orders
USING (customer_id)
JOIN order_items
USING(order_id)
WHERE customer_id = 1296
GROUP BY customers.firstname, customers.lastname

-- calculating revenue for the first month 
SELECT DATE_TRUNC('week', orders.shipped_date) :: DATE AS shipped_week,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM orders
JOIN order_items
USING(order_id)
WHERE DATE_TRUNC('month',orders.shipped_date) = '2017-08-01'
GROUP BY shipped_week
ORDER BY shipped_week

-- total cost since the bikestore started operating 
SElECT ROUND(SUM(quantity * product_cost))
FROM stocks
JOIN products 
USING(product_id)

-- calculating top 5 bikes with the highest cost
SELECT
products.product_id,
products.product_name,
ROUND(SUM(stocks.quantity * products.product_cost)) AS cost
FROM stocks 
JOIN products
USING (product_id)
GROUP BY products.product_id, products.product_name 
ORDER BY cost DESC 
LIMIT 5

-- Placing the cost per month in a CTE then calculating the average cost before 2015-09-01
WITH monthly_cost AS (
	SELECT DATE_TRUNC('month', stocks.stocking_date) :: DATE AS stocking_month,
	ROUND(SUM(stocks.quantity * products.product_cost)) AS cost
	FROM stocks
	JOIN products
	USING(product_id)
	GROUP BY stocking_month) 

SELECT AVG(cost)
FROM monthly_cost
WHERE stocking_month < '2015-09-01'

-- Calculating profit per Bike stores
WITH revenue AS (
SELECT stores.store_name,
ROUND(SUM(order_items.list_price * order_items.quantity)) - ROUND(SUM(1-order_items.discount)) AS REVENUE
FROM stores 
JOIN orders
USING (store_id)
JOIN order_items 
USING(order_id)
GROUP BY stores.store_name
), 
cost AS ( 
SELECT stores.store_name,
ROUND(SUM(stocks.quantity * products.product_cost)) AS cost
FROM stores 
JOIN stocks
USING (store_id)
JOIN products 
USING(product_id)
GROUP BY stores.store_name
)
SELECT revenue.store_name,
revenue - cost as profit
from revenue
join cost 
on revenue.store_name = cost.store_name 
order by profit DESC
