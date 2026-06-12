# Brazilian-E-Commerce-Public-Dataset-by-O
Order Receiving Performance Analytics Dashboard. Analyze high-volume order transactions to identify order quality issues, customer behavior patterns, operational bottlenecks, and performance drivers across multiple sales channels
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
