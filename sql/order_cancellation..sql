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

WITH cancellation as 
(
  SELECT
  a.order_id,
  b.product_id,
  d.product_category_name_english as product_name


  FROM `amplified-cache-495313-g5.Olist.orders` a
  LEFT JOIN `amplified-cache-495313-g5.Olist.order_items` b on a.order_id=b.order_id
  LEFT JOIN `amplified-cache-495313-g5.Olist.products` c on b.product_id=c.product_id
  INNER JOIN `amplified-cache-495313-g5.Olist.category_name_translation1` d on c.product_category_name=d.product_category_name
WHERE a.order_status = 'canceled'
)
-- SELECT
--   count(order_id) as count_product
-- FROM cancellation;

SELECT
  product_name,
  COUNT(order_id) as count_product
FROM cancellation
GROUP BY 1
ORDER BY 2 DESC;
