-- Frequency of orders delivered every month
SELECT
  DATE(DATE_TRUNC(order_purchase_timestamp, YEAR)) AS year,
  DATE(DATE_TRUNC(order_purchase_timestamp, MONTH)) AS month,
  COUNT(DISTINCT order_id) AS total_orders

FROM `amplified-cache-495313-g5.Olist.orders`
WHERE order_status = 'delivered'
GROUP BY 1, 2
ORDER BY 1, 2
;

-- Top 10 cities with most number of orders
SELECT
  c.customer_state,
  c.customer_city,
  COUNT(o.order_id) AS total_orders

FROM `Olist.orders` AS o
JOIN `Olist.customers` AS c
ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
GROUP BY 1, 2
ORDER BY total_orders DESC
LIMIT 10
;

-- Deliveries by hour (peak)
SELECT
  EXTRACT(HOUR FROM order_delivered_customer_date) AS hour,
  COUNT(*) AS orders_delivered

FROM `Olist.orders`
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 1
;

-- Average difference between order and delivery time by state
SELECT
  c.customer_state,
  AVG(
    TIMESTAMP_DIFF(
      o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) 
      AS avg_delivery_time_days
FROM `Olist.orders` AS o
JOIN `Olist.customers` AS c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
;

