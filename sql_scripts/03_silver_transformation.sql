/*
==========================================================
STEP 03: DATA TRANSFORMATION (SILVER LAYER)
==========================================================
Descripción: Creación de Vistas (Views) para limpieza.
Acciones: 
 - Conversión de fechas (String a Timestamp).
 - Normalización de texto (Lower, Trim).
 - Tratamiento de valores nulos (Coalesce).
==========================================================
*/

-- VISTA 1: Órdenes Limpias
-- 1. VISTA: silver_orders (Limpieza de fechas)-- 1. VISTA: silver_orders (Limpieza de fechas)
CREATE OR REPLACE VIEW silver_orders AS
SELECT 
    order_id,
    customer_id,
    order_status,
    -- Usamos 'orders' que es el nombre de tu tabla actual
    CAST(order_purchase_timestamp AS TIMESTAMP) AS purchase_at,
    CAST(order_approved_at AS TIMESTAMP) AS approved_at,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_at,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_at
FROM orders; 

-- 2. VISTA: silver_products (Normalización y Traducción)
CREATE OR REPLACE VIEW silver_products AS
SELECT 
    p.product_id,
    -- Limpiamos el texto y manejamos nulos
    TRIM(LOWER(COALESCE(t.product_category_name_english, 'others'))) AS category,
    p.product_weight_g,
    p.product_length_cm
FROM products p
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name;

-- 3. VISTA: silver_order_items (Versión Robusta para Aden)
CREATE OR REPLACE VIEW silver_order_items AS
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    -- Forzamos a que el resultado del COALESCE sea exactamente numeric(10,2)
    COALESCE(CAST(price AS NUMERIC(10,2)), 0)::numeric(10,2) AS price,
    COALESCE(CAST(freight_value AS NUMERIC(10,2)), 0)::numeric(10,2) AS freight_value,
    -- Hacemos lo mismo para el total
    (COALESCE(CAST(price AS NUMERIC(10,2)), 0) + COALESCE(CAST(freight_value AS NUMERIC(10,2)), 0))::numeric(10,2) AS total_item_value
FROM order_items;

-- 4. VISTA: silver_order_reviews (Fechas y Textos)
-- Convertir varchar en timestamp y limpiar comentarios.
CREATE OR REPLACE VIEW silver_order_reviews AS
SELECT 
    review_id,
    order_id,
    review_score,
    -- Limpieza de texto: quitamos espacios y manejamos vacíos
    TRIM(review_comment_title) AS review_title,
    TRIM(review_comment_message) AS review_message,
    -- Transformación de Fechas
    CAST(review_creation_date AS TIMESTAMP) AS created_at,
    CAST(review_answer_timestamp AS TIMESTAMP) AS answered_at
FROM order_reviews;

-- 5. VISTA: silver_customers (Normalización Geográfica)
-- Geolocalización: estados y ciudades consistentes.
CREATE OR REPLACE VIEW silver_customers AS
SELECT 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix AS zip_code,
    LOWER(TRIM(customer_city)) AS city, -- evita SAO PAULO, sao paulo, Sao Paulo (espacio al final), etc
    UPPER(TRIM(customer_state)) AS state -- Siempre en mayúsculas (SP, RJ, etc)
FROM customers;


-- 6. VISTA: silver_sellers (Normalización Geográfica Vendedores)
-- Ubicación: estados y ciudades consistentes.(ubicación vendedores)
CREATE OR REPLACE VIEW silver_sellers AS
SELECT 
    seller_id,
    seller_zip_code_prefix AS zip_code,
    LOWER(TRIM(seller_city)) AS city,
    UPPER(TRIM(seller_state)) AS state
FROM sellers;

-- 7. VISTA: silver_order_payment (Pagos)
-- NuméricoPagos: con amplitud decimal
CREATE OR REPLACE VIEW silver_order_payments AS
SELECT 
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    CAST(payment_value AS NUMERIC(10,2)) AS payment_value
FROM order_payments;


--- Prueba
SELECT viewname FROM pg_views WHERE viewname LIKE 'silver_%';