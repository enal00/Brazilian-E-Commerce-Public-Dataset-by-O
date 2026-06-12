-- Which sales channels generate the highest order volume?
WITH a as
(
  SELECT
  payment_type,
  order_id,
  payment_value
  FROM `amplified-cache-495313-g5.Olist.order_payments`
)

SELECT
  payment_type,
  COUNT(order_id) as count_id,
  SUM(payment_value) as sum_payment
FROM a
GROUP BY 1
ORDER BY 2 DESC
;

CREATE OR REPLACE TABLE `amplified-cache-495313-g5.Olist.category_name_translation1` AS
SELECT
  string_field_0 AS product_category_name,
  string_field_1 AS product_category_name_english
FROM
(
  SELECT *, ROW_NUMBER() OVER (ORDER BY string_field_0)AS rn
  FROM `amplified-cache-495313-g5.Olist.category_name_translation`
) 
WHERE rn > 1;
-- Which products have the highest cancellation rates?

WITH orders_all AS (
  SELECT
    b.product_id,
    d.product_category_name_english AS product_name,
    a.order_id,
    a.order_status
  FROM `amplified-cache-495313-g5.Olist.orders` a
  LEFT JOIN `amplified-cache-495313-g5.Olist.order_items` b 
    ON a.order_id = b.order_id
  LEFT JOIN `amplified-cache-495313-g5.Olist.products` c 
    ON b.product_id = c.product_id
  INNER JOIN `amplified-cache-495313-g5.Olist.category_name_translation1` d 
    ON c.product_category_name = d.product_category_name
),
agg AS (
  SELECT
    product_name,
    COUNT(order_id) AS total_orders,
    COUNTIF(order_status = 'canceled') AS canceled_orders
  FROM orders_all
  GROUP BY product_name
)

SELECT
  product_name,
  total_orders,
  canceled_orders,
  SAFE_DIVIDE(canceled_orders, total_orders) * 100 AS cancellation_rate_pct
FROM agg
ORDER BY cancellation_rate_pct DESC;
