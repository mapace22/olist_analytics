-- =============================================================================
-- PROYECTO: Olist E-commerce - Carga de Datos (Archivo 02)
-- DESCRIPCIÓN: Ingesta de archivos CSV desde el disco D:
-- =============================================================================

/*
==========================================================
STEP 02: DATA INGESTION (BRONZE LAYER)
==========================================================
Descripción: Carga masiva de datos desde archivos CSV.
Origen: Dataset original de Olist.
Destino: Tablas crudas (Raw Data).
==========================================================
*/

SET search_path TO public;

-- TRACTO 1: Maestras
COPY customers FROM '/datos/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY products FROM '/datos/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;
COPY sellers FROM '/datos/olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY category_translation FROM '/datos/product_category_name_translation.csv' DELIMITER ',' CSV HEADER;

-- TRACTO 2: Transaccionales
COPY orders FROM '/datos/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_items FROM '/datos/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_payments FROM '/datos/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_reviews FROM '/datos/olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;


SELECT 'Clientes' as tabla, COUNT(*) FROM customers
UNION ALL
SELECT 'Productos', COUNT(*) FROM products
UNION ALL
SELECT 'Vendedores', COUNT(*) FROM sellers
UNION ALL
SELECT 'Pedidos (Orders)', COUNT(*) FROM orders
UNION ALL
SELECT 'Items de Pedidos', COUNT(*) FROM order_items
UNION ALL
SELECT 'Pagos', COUNT(*) FROM order_payments
UNION ALL
SELECT 'Reseñas', COUNT(*) FROM order_reviews;