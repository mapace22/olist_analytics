/*
==========================================================
STEP 04: BUSINESS INTELLIGENCE (GOLD LAYER)
==========================================================
Descripción: Consultas finales de alto valor.
Objetivo: Responder preguntas de negocio y preparar 
          datos para Python/Visualización.
==========================================================
*/

-- 1. Análisis de Ventas Geográfico (¿Dónde está el dinero?)
-- Usamos silver_orders y silver_order_items
SELECT 
    c.customer_state AS estado,
    COUNT(DISTINCT o.order_id) AS total_pedidos,
    ROUND(SUM(i.total_item_value), 2) AS ingresos_totales -- Ya tenemos el total calculado en Silver
FROM silver_orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN silver_order_items i ON o.order_id = i.order_id
GROUP BY estado
ORDER BY ingresos_totales DESC
LIMIT 5;

-- 2. Comportamiento de Entregas (¿Somos rápidos?)
-- Gracias a Silver, las fechas ya son TIMESTAMPS, podemos restarlas directamente
SELECT 
    AVG(delivered_at - purchase_at) AS tiempo_promedio_entrega
FROM silver_orders
WHERE order_status = 'delivered';

-- 3. Los Productos "Estrella"
-- Ya no necesitamos unir la tabla de traducción, silver_products ya la tiene
SELECT 
    category, 
    COUNT(*) AS unidades_vendidas
FROM silver_order_items i
JOIN silver_products p ON i.product_id = p.product_id
GROUP BY category
ORDER BY unidades_vendidas DESC
LIMIT 10;

-- 4. Análisis de Logística (Días de retraso)
SELECT 
    order_status,
    COUNT(*) as total,
    AVG(delivered_at - estimated_at) as diferencia_promedio
FROM silver_orders
WHERE delivered_at IS NOT NULL
GROUP BY order_status;

-- 5. Concentración de Vendedores
SELECT 
    s.seller_state, 
    COUNT(DISTINCT s.seller_id) as cantidad_vendedores,
    ROUND(SUM(i.total_item_value), 2) as ventas_por_estado
FROM silver_order_items i
JOIN sellers s ON i.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY ventas_por_estado DESC;


-- Gran Expediente Maestro
-- DROP VIEW IF EXISTS gold_master_orders;
CREATE VIEW gold_master_orders AS
SELECT 
    -- 1. IDENTIFICADORES (Para análisis)
    o.order_id,
    c.customer_unique_id,
    -- 2. CATEGÓRICOS LIMPIOS (Imputación de 'unknown')
    o.order_status,
    c.city AS customer_city,
    c.state AS customer_state,
    COALESCE(p.category, 'unknown') AS product_category_english,
    -- 3. FINANCIEROS (Imputación de 0)
    COALESCE(i.price, 0)::numeric(10,2) AS price,
    COALESCE(i.freight_value, 0)::numeric(10,2) AS freight_value,
    COALESCE(i.total_item_value, 0)::numeric(10,2) AS total_item_value,
    -- 4. LOGÍSTICA Y PESO (Imputación de 0 y -9999)
    COALESCE(p.product_weight_g, 0) AS product_weight_g,
    EXTRACT(DAY FROM (o.estimated_at - o.purchase_at)) AS estimated_days,
    COALESCE(
        (EXTRACT(DAY FROM (o.delivered_at - o.purchase_at)) - 
         EXTRACT(DAY FROM (o.estimated_at - o.purchase_at))), 
        -9999
    ) AS delivery_disparity_days,
    -- 5. CARACTERÍSTICAS BINARIAS
    (COALESCE(i.freight_value, 0) / (COALESCE(i.price, 0) + 1))::numeric(10,4) AS freight_price_ratio,
    CASE WHEN pay.payment_type = 'credit_card' THEN 1 ELSE 0 END AS is_credit_card,
    CASE WHEN c.state IN ('SP', 'RJ') THEN 1 ELSE 0 END AS is_major_capital,
    -- 6. VARIABLE OBJETIVO
    CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END AS risk_insatisfaction,
    r.review_score
FROM silver_orders o
LEFT JOIN silver_customers c ON o.customer_id = c.customer_id
LEFT JOIN silver_order_items i ON o.order_id = i.order_id
LEFT JOIN silver_products p ON i.product_id = p.product_id
LEFT JOIN silver_order_reviews r ON o.order_id = r.order_id
LEFT JOIN silver_order_payments pay ON o.order_id = pay.order_id;

-- ¿Tenemos los 119,143 registros de Python?
SELECT COUNT(*) FROM gold_master_orders;

-- Satisfacción del Cliente y ciudades que más gastan (TOP 5)
-- Mix money with sentiment
-- ¿Cuáles son las 5 ciudades que más gastan y su promedio de satisfacción?
SELECT customer_city, 
    ROUND(AVG(review_score), 2) as avg_satisfaction,
    SUM(total_item_value) as total_sales
FROM gold_master_orders
GROUP BY 1
ORDER BY total_sales DESC
LIMIT 5;

-- Análisis de "Categorías Peligrosas"
-- ¿Dónde están los problemas? Categorías que tienen un volumen de ventas alto pero un riesgo de insatisfacción preocupante.
SELECT 
    product_category_english,
    COUNT(order_id) as total_ventas,
    ROUND(AVG(review_score), 2) as satisfaction_avg,
    SUM(risk_insatisfaction) as cantidad_clientes_en_riesgo,
    ROUND((SUM(risk_insatisfaction)::numeric / COUNT(order_id)::numeric) * 100, 2) as porcentaje_riesgo
FROM gold_master_orders
WHERE product_category_english != 'unknown'
GROUP BY 1
HAVING COUNT(order_id) > 100 -- Filtramos categorías pequeñas para no sesgar
ORDER BY porcentaje_riesgo DESC
LIMIT 10;