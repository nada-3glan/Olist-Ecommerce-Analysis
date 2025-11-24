--Customer Dimension
SELECT * 
FROM customers


--Seller Dimension
SELECT * 
FROM sellers


--Product Dimension
SELECT 
    P.product_id,
    ISNULL(PT.product_category_name_english, 'Unknown') AS product_category_name_english,
    P.product_description_lenght,
    P.product_height_cm,
    P.product_width_cm,
    P.product_weight_g,
    P.product_length_cm,
    P.product_photos_qty
FROM products P
LEFT JOIN product_category_name_translation PT 
    ON P.product_category_name = PT.product_category_name
WHERE P.product_id IS NULL;







--Review Dimension
SELECT
    o.order_id,
    o.customer_id,
    oi.seller_id,
    oi.product_id,
    r.review_id,
	o.order_status,

    CAST(o.order_purchase_timestamp AS DATE) AS order_purchase_timestamp,
    CAST(o.order_delivered_carrier_date AS DATE) AS order_delivered_carrier_date,
    CAST(o.order_delivered_customer_date AS DATE) AS order_delivered_customer_date,
    CAST(o.order_estimated_delivery_date AS DATE) AS order_estimated_delivery_date,

    SUM(oi.price) AS price,                         
    SUM(oi.freight_value) AS freight_value,         
    SUM(pay.payment_value) AS payment_value         
FROM orders o
LEFT JOIN order_items oi 
       ON o.order_id = oi.order_id
LEFT JOIN order_payments pay
       ON o.order_id = pay.order_id
LEFT JOIN olist_order_reviews_dataset r
       ON o.order_id = r.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    oi.seller_id,
    oi.product_id,
    r.review_id,
	o.order_status,
    CAST(o.order_purchase_timestamp AS DATE),
    CAST(o.order_delivered_carrier_date AS DATE),
    CAST(o.order_delivered_customer_date AS DATE),
    CAST(o.order_estimated_delivery_date AS DATE)
ORDER BY o.order_id;






--Payment-Fact Dimension
SELECT
    op.order_id,
    o.customer_id,
    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM order_payments op
INNER JOIN orders o
    ON op.order_id = o.order_id
ORDER BY op.order_id, op.payment_sequential;












