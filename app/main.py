from fastapi import FastAPI, HTTPException
import joblib
import os
import pandas as pd
from pydantic import BaseModel

app = FastAPI(title="Olist Analytics API - Predictor Real")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
model = joblib.load(os.path.join(BASE_DIR, "rf_best_model.joblib"))
scaler = joblib.load(os.path.join(BASE_DIR, "scaler.joblib"))

# Obtenemos la lista exacta de lo que el modelo espera
EXPECTED_COLUMNS = list(scaler.feature_names_in_)

# Definimos los datos que Pedro (el usuario) realmente conoce
class DatosCliente(BaseModel):
    price: float
    freight_value: float
    product_weight_g: float
    estimated_days: float

@app.get("/")
def home():
    return {"status": "Online", "modelo": "Cargado", "columnas_modelo": len(EXPECTED_COLUMNS)}

@app.post("/predict")
def predict(data: DatosCliente):
    try:
        # 1. Creamos un DataFrame con ceros usando los nombres exactos del modelo
        df_final = pd.DataFrame(0.0, index=[0], columns=EXPECTED_COLUMNS)
        
        # 2. Llenamos solo los datos que recibimos del usuario
        # Usamos los nombres que aparecen en tu lista de COLUMNAS
        df_final["price"] = data.price
        df_final["freight_value"] = data.freight_value
        df_final["product_weight_g"] = data.product_weight_g
        df_final["estimated_days"] = data.estimated_days
        
        # 3. Cálculos automáticos para variables derivadas (opcional pero ayuda)
        df_final["total_item_value"] = data.price + data.freight_value
        if data.price > 0:
            df_final["freight_price_ratio"] = data.freight_value / data.price

        # 4. Escalar y Predecir
        df_scaled = scaler.transform(df_final)
        prediccion = model.predict(df_scaled)[0]
        probabilidad = model.predict_proba(df_scaled)[0][1]
        
        return {
            "insatisfecho": int(prediccion),
            "probabilidad_riesgo": round(float(probabilidad), 4),
            "mensaje": "Crítico" if probabilidad > 0.6 else "Estable"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))