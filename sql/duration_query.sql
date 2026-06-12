-- What drives delayed order fulfillment?
-- Make a querry of duration order_estimated_delivery_date

WITH duration AS (
  SELECT
    order_id,
    TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, HOUR) AS seller_duration,
    TIMESTAMP_DIFF(order_delivered_carrier_date, order_approved_at, HOUR) AS seller_carrier_duration,
    TIMESTAMP_DIFF(order_delivered_customer_date, order_delivered_carrier_date, HOUR) AS carrier_duration,
    TIMESTAMP_DIFF(order_estimated_delivery_date, order_purchase_timestamp, HOUR ) AS target_duration
  FROM `amplified-cache-495313-g5.Olist.orders`
  WHERE order_status = 'delivered'
),
quartiles AS (
  SELECT
    APPROX_QUANTILES(seller_duration, 4)[OFFSET(1)] AS Q1_seller,
    APPROX_QUANTILES(seller_duration, 4)[OFFSET(3)] AS Q3_seller,
    APPROX_QUANTILES(seller_carrier_duration, 4)[OFFSET(1)] AS Q1_seller_carrier,
    APPROX_QUANTILES(seller_carrier_duration, 4)[OFFSET(3)] AS Q3_seller_carrier,
    APPROX_QUANTILES(carrier_duration, 4)[OFFSET(1)] AS Q1_carrier,
    APPROX_QUANTILES(carrier_duration, 4)[OFFSET(3)] AS Q3_carrier,
    APPROX_QUANTILES(carrier_duration, 4)[OFFSET(1)] AS Q1_target,
    APPROX_QUANTILES(carrier_duration, 4)[OFFSET(3)] AS Q3_target
  FROM duration
),
calc AS (
  SELECT
    d.*,
    q.Q1_seller, q.Q3_seller,
    q.Q1_seller_carrier, q.Q3_seller_carrier,
    q.Q1_carrier, q.Q3_carrier,
    q.Q1_target, q.Q3_target
  FROM duration d
  CROSS JOIN quartiles q
),
duration_clean AS (
SELECT
  order_id,
  seller_duration,
  seller_carrier_duration,
  carrier_duration,
  target_duration
FROM calc
WHERE seller_duration BETWEEN Q1_seller - 1.5*(Q3_seller - Q1_seller) AND Q3_seller + 1.5*(Q3_seller - Q1_seller)
  AND seller_carrier_duration BETWEEN Q1_seller_carrier - 1.5*(Q3_seller_carrier - Q1_seller_carrier) AND Q3_seller_carrier + 1.5*(Q3_seller_carrier - Q1_seller_carrier)
  AND carrier_duration BETWEEN Q1_carrier - 1.5*(Q3_carrier - Q1_carrier) AND Q3_carrier + 1.5*(Q3_carrier - Q1_carrier)
  AND target_duration BETWEEN Q1_target - 1.5*(Q3_target - Q1_target) AND Q3_target + 1.5*(Q3_target - Q1_target)
),
avg_durasi AS (
  SELECT
    AVG(seller_duration) AS avg_seller,
    AVG(seller_carrier_duration) AS avg_seller_carrier,
    AVG(carrier_duration) AS avg_carrier
  FROM duration_clean
),
-- durasi waktu total lebih besar dibanding durasi target
delay_orders AS (
  SELECT
  order_id,
  seller_duration,
  seller_carrier_duration,
  carrier_duration,
  seller_duration + seller_carrier_duration + carrier_duration AS total_duration,
  target_duration
  FROM duration_clean
  WHERE seller_duration + seller_carrier_duration + carrier_duration - target_duration > 0
),
flag AS (
SELECT
  f.order_id,
  f.seller_duration,
  f.seller_carrier_duration,
  f.carrier_duration,
  f.total_duration,
  f.target_duration,
  a.avg_seller,
  a.avg_seller_carrier,
  a.avg_carrier,

  IF(f.seller_duration > a.avg_seller, 1, 0) AS seller_above_avg,
  IF(f.seller_carrier_duration > a.avg_seller_carrier, 1, 0) AS seller_carrier_above_avg,
  IF(f.carrier_duration > a.avg_carrier, 1, 0) AS carrier_above_avg
FROM delay_orders f
CROSS JOIN avg_durasi a
)

-- SELECT *
-- FROM flag LIMIT 10;

SELECT
SUM (seller_above_avg) as count_seller_delay, --(approve/admin – invoiced/werehousing – processing /packing), 
SUM (seller_carrier_above_avg)as count_seller_carrier_delay, --(shipping seller/dropping)
SUM (carrier_above_avg)as count_carrier_delay, --(admin carrier/shipping carrier)
count(order_id) AS total_delay_count
FROM flag
