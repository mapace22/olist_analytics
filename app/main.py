from fastapi import FastAPI, HTTPException
import joblib
import os
import pandas as pd
from pydantic import BaseModel

# 1. Configuración y carga
app = FastAPI(title="Olist Analytics API - Predictor de Riesgo")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Cargamos los archivos que ya tienes en la carpeta
model = joblib.load(os.path.join(BASE_DIR, "rf_best_model.joblib"))
scaler = joblib.load(os.path.join(BASE_DIR, "scaler.joblib"))

# 2. Esquema de datos: Lo que Pedro debe enviarnos
class DatosCliente(BaseModel):
    distancia_km: float
    tiempo_entrega_est: float
    precio_producto: float
    valor_flete: float

@app.get("/")
def home():
    return {"status": "Online", "modelo": "Cargado y listo"}

# 3. RUTA DE PREDICCIÓN: Aquí ocurre la magia
@app.post("/predict")
def predict(data: DatosCliente):
    try:
        # 1. Crear el DataFrame con los datos de Pedro
        df_input = pd.DataFrame([data.dict()])
        
        # 2. RELLENO DE COLUMNAS FALTANTES
        # Obtenemos los nombres de columnas que espera el modelo (del scaler)
        expected_columns = scaler.feature_names_in_
        
        # Creamos un DataFrame vacío con todas las columnas necesarias llenas de 0
        df_final = pd.DataFrame(0, index=[0], columns=expected_columns)
        
        # Sobreescribimos solo los valores que Pedro nos envió
        for col in df_input.columns:
            if col in df_final.columns:
                df_final[col] = df_input[col]
        
        # 3. Escalar y Predecir
        df_scaled = scaler.transform(df_final)
        prediccion = model.predict(df_scaled)[0]
        probabilidad = model.predict_proba(df_scaled)[0][1]
        
        return {
            "insatisfecho": int(prediccion),
            "probabilidad_riesgo": round(float(probabilidad), 2),
            "mensaje": "Alto riesgo" if prediccion == 1 else "Bajo riesgo"
        }
    except Exception as e:
        # Esto nos dirá exactamente qué falla si vuelve a pasar
        print(f"Error detallado: {e}")
        raise HTTPException(status_code=500, detail=str(e))