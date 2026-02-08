from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests

def test_api():
    # Intenta conectar con tu contenedor de la API
    response = requests.get("http://app:8000/")
    print(f"Respuesta de la API: {response.status_code}")

default_args = {
    'owner': 'marcel',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 8),
    'retries': 1,
}

with DAG(
    '01_prueba_de_vida',
    default_args=default_args,
    description='Verifica conexión entre Airflow y API',
    schedule_interval=None, # Solo se ejecuta cuando tú le des al botón
    catchup=False
) as dag:

    tarea_saludar = PythonOperator(
        task_id='saludar_api',
        python_callable=test_api
    )