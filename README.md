# 📊 Olist Analytics: Predicción de Riesgo de Insatisfacción

Este proyecto integra un ecosistema de datos completo para predecir la insatisfacción del cliente en la plataforma Olist mediante Machine Learning y automatización industrial.

## 🏗️ Estructura del Proyecto (Actualizada)

* **app/**: API (FastAPI) y modelo entrenado (`RandomForest`).
* **dags/**: Orquestación de procesos con **Apache Airflow**.
* **sql_scripts/**: Lógica de transformación en base de datos.
* **docker-compose.yml**: Configuración de todo el entorno (DB, API, Airflow).

## 🛠️ Tecnologías Principales

* **FastAPI**: Servicio de predicciones en tiempo real.
* **Apache Airflow**: Automatización y orquestación de tareas (ETL).
* **PostgreSQL**: Almacenamiento de datos transaccionales y analíticos.
* **Docker & Docker Compose**: Contenedorización de toda la infraestructura.

## 🚀 Cómo ejecutar (Modo Docker)

Ya no es necesario activar entornos virtuales manualmente. Todo se levanta con un solo comando:

1. **Levantar infraestructura:**
   `docker-compose up -d`

2. **Acceder a los servicios:**
   - **API:** `http://localhost:8000`
   - **Airflow:** `http://localhost:8080` (User: `admin` / Pass: `admin`)
   - **Base de Datos:** Puerto `5432`

## 📬 Estado del Proyecto

- [x] Contenedorización de Base de Datos y API.
- [x] Configuración de Apache Airflow en Docker.
- [x] Prueba de conexión Airflow -> API (Exitosa: HTTP 200).
- [ ] Implementación de DAG para procesamiento automático de ventas.
- [ ] Integración con LangChain para interfaz de chat inteligente.