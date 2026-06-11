-- What drives delayed order fulfillment?
-- Make a table duration

WITH duration AS (
  SELECT
    order_id,
    TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, HOUR) AS seller_duration,
    TIMESTAMP_DIFF(order_delivered_carrier_date, order_approved_at, HOUR) AS seller_carrier_duration,
    TIMESTAMP_DIFF(order_delivered_customer_date, order_delivered_carrier_date, HOUR) AS carrier_duration
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
    APPROX_QUANTILES(carrier_duration, 4)[OFFSET(3)] AS Q3_carrier
  FROM duration
),
calc AS (
  SELECT
    d.*,
    q.Q1_seller, q.Q3_seller,
    q.Q1_seller_carrier, q.Q3_seller_carrier,
    q.Q1_carrier, q.Q3_carrier
  FROM duration d
  CROSS JOIN quartiles q
)
SELECT
  order_id,
  seller_duration,
  seller_carrier_duration,
  carrier_duration
FROM calc
WHERE seller_duration BETWEEN Q1_seller - 1.5*(Q3_seller - Q1_seller) AND Q3_seller + 1.5*(Q3_seller - Q1_seller)
  AND seller_carrier_duration BETWEEN Q1_seller_carrier - 1.5*(Q3_seller_carrier - Q1_seller_carrier) AND Q3_seller_carrier + 1.5*(Q3_seller_carrier - Q1_seller_carrier)
  AND carrier_duration BETWEEN Q1_carrier - 1.5*(Q3_carrier - Q1_carrier) AND Q3_carrier + 1.5*(Q3_carrier - Q1_carrier)
ORDER BY carrier_duration DESC
LIMIT 150;
