import requests

# La dirección de tu API (la que ves en la terminal izquierda)
URL = "http://127.0.0.1:8000/predict"

# Una lista de pedidos (Batch)
pedidos = [
    {"distancia_km": 50.0, "tiempo_entrega_est": 2.0, "precio_producto": 40.0, "valor_flete": 10.0},
    {"distancia_km": 800.0, "tiempo_entrega_est": 15.0, "precio_producto": 200.0, "valor_flete": 45.0},
    {"distancia_km": 3000.0, "tiempo_entrega_est": 45.0, "precio_producto": 500.0, "valor_flete": 120.0}
]

print("🚀 Iniciando prueba múltiple para Vincent...\n")

for i, datos in enumerate(pedidos, 1):
    response = requests.post(URL, json=datos)
    if response.status_code == 200:
        resultado = response.json()
        print(f"Pedido #{i}: {resultado['mensaje']} (Riesgo: {resultado['probabilidad_riesgo']})")
    else:
        print(f"Pedido #{i}: Error {response.status_code}")

print("\n✅ Prueba terminada.")