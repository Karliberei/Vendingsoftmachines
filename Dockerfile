# 1. Utiliza uma imagem oficial de Python leve como base
FROM python:3.10-slim

# 2. Define o diretório de trabalho dentro do container
WORKDIR /app

# 3. Instala dependências do sistema necessárias para comunicações e compilações de bibliotecas
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# 4. Copia o ficheiro de requisitos de dependências primeiro (otimiza a cache do Docker)
COPY requirements.txt .

# 5. Instala as bibliotecas Python necessárias (ex: pyserial, asyncio, etc.)
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copia todo o código fonte da lógica da vending machine para o container
COPY . .

# 7. Define o ponto de entrada único e confiável para iniciar o simulador/controlador
CMD ["python", "Venda da vending.py"]
pyserial==3.5


docker run -d --device=/dev/ttyUSB0:/dev/ttyUSB0 vending-app
