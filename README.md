# 📊 Olist Analytics: Predicción de Riesgo de Insatisfacción

Este proyecto integra un modelo de Machine Learning para predecir la insatisfacción del cliente en la plataforma Olist, permitiendo tomar acciones proactivas.

## 🏗️ Estructura del Proyecto
* **`app/`**: Contiene la API (**FastAPI**) y el modelo entrenado (`.joblib`).
* **`sql_scripts/`**: Scripts de SQL para el procesamiento de datos (Bronze/Silver/Gold).
* **`notebooks/`**: Experimentos iniciales y entrenamiento del modelo.
* **`csv_data/`**: Datasets originales de Olist.

## 🛠️ Tecnologías Principales
* **FastAPI** & **Uvicorn**: Para servir el modelo en tiempo real.
* **Scikit-learn**: Para la lógica de predicción (Random Forest).
* **Git**: Para el control de versiones profesional.

## 🚀 Cómo ejecutar
1. **Activar entorno:** `source app/venv/bin/activate`
2. **Instalar dependencias:** `pip install -r app/requirements.txt`
3. **Iniciar API:** `uvicorn app.main:app --reload`

## 📬 Próximos Pasos (Roadmap)
* **Apache Airflow**: Automatización del flujo de datos.
* **LangChain**: Interfaz de chat inteligente