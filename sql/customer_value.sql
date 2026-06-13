-- Which customers are most valuable?

WITH customer_orders AS (
  SELECT

    o.order_id,
    o.customer_id,
    i.price,
    i.freight_value,
    c.customer_unique_id,
    c.customer_zip_code_prefix
  
  FROM `amplified-cache-495313-g5.Olist.orders` o
  LEFT JOIN `amplified-cache-495313-g5.Olist.order_items` i 
    on o.order_id = i.order_id
  LEFT JOIN `amplified-cache-495313-g5.Olist.customers` c 
    on o.customer_id = c.customer_id
  WHERE order_status = 'delivered'
)

SELECT
 customer_id, customer_zip_code_prefix,
 SUM(price + freight_value) AS total_order_value
FROM customer_orders

GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5
;
