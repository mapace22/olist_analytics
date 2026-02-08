# 1. Usar una imagen de Python ligera
FROM python:3.9-slim

# 2. Establecer el directorio de trabajo
WORKDIR /app

# 3. Copiar los archivos de requerimientos e instalar dependencias
# Nota: Asegúrate de tener un archivo requirements.txt o las instalamos directo:
RUN pip install --no-cache-dir fastapi uvicorn joblib pandas scikit-learn

# 4. Copiar el resto del código de la carpeta app
COPY ./app /app/app

# 5. Comando para iniciar la API
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]