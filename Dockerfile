# 1. Utiliza uma imagem oficial de Python leve como base
FROM python:3.10-slim


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
# Usa una imagen oficial de Python
FROM python:3.10-slim

# Define el directorio de trabajo
WORKDIR /app

# Copia los requisitos e instala las dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código
COPY . .

# Expone el puerto (ajusta según lo que use tu app o el servidor)
EXPOSE 8080

# Arranca la aplicación (asegúrate de usar la variable de entorno PORT si el servidor lo pide)
CMD ["python", "app.py"]


docker run -d --device=/dev/ttyUSB0:/dev/ttyUSB0 vending-app


# src/main.py
import asyncio
from hardware.mdb import MDBController

# Instancia o controlador (ajuste a porta conforme o seu hardware)
mdb = MDBController(port='/dev/ttyUSB0')
mdb.conectar()

saldo_atual = 0.0

async def mdb_polling_task():
    """Tarefa em segundo plano que corre junto com o Kivy/Asyncio"""
    global saldo_atual
    while True:
        # Executa de forma assíncrona sem travar o ecrã
        valor_inserido = mdb.verificar_moedas()
        
        if valor_inserido:
            saldo_atual += valor_inserido
            print(f"🪙 Saldo Atualizado: {saldo_atual}€")
            # Aqui aciona a função da sua FSM para atualizar o ecrã do Kivy
            # exemplo: app.root.atualizar_ecran_saldo(saldo_atual)
            
        # Pausa recomendada de 200ms do protocolo MDB
        await asyncio.sleep(0.2)

# No método de inicialização da sua App (onde usa o asyncio.ensure_future):
# asyncio.ensure_future(mdb_polling_task())

docker run -d --device=/dev/ttyUSB0:/dev/ttyUSB0 vending-app



python "Venda da vending.py"


from telemetry import report_sale_to_cloud, report_stock_alert


import asyncio
import aiohttp
import logging
from decimal import Decimal
from datetime import datetime

logger = logging.getLogger("VendingTelemetry")

# URL do servidor central de telemetria (substitua pelo seu endpoint de produção/Fly.io)
TELEMETRY_ENDPOINT = "https://vendingsoftmachines.com"

async def send_telemetry_event(payload: dict) -> bool:
    """
    Envia um payload JSON de forma assíncrona para o servidor central.
    Garante que falhas de rede na nuvem não quebrem o funcionamento físico da máquina.
    """
    try:
        # Timeout curto para evitar que conexões presas consumam memória no Android
        timeout = aiohttp.ClientTimeout(total=5.0)
        
        async with aiohttp.ClientSession(timeout=timeout) as session:
            async with session.post(TELEMETRY_ENDPOINT, json=payload) as response:
                if response.status == 200 or response.status == 201:
                    logger.info(f"📊 Telemetria enviada com sucesso: {payload.get('event_type')}")
                    return True
                else:
                    logger.warning(f"⚠️ Servidor rejeitou telemetria. Status: {response.status}")
                    return False
    except asyncio.TimeoutError:
        logger.error("❌ Timeout ao tentar contactar o servidor de telemetria (Rede lenta).")
        return False
    except Exception as e:
        # Importante: Captura falhas de falta de internet sem deitar a máquina abaixo
        logger.error(f"❌ Falha crítica de rede na telemetria: {e}")
        return False

# Funções auxiliares especializadas que o motor da máquina vai chamar
async def report_sale_to_cloud(machine_id: str, code: str, name: str, price: Decimal):
    """Notifica a nuvem sobre uma venda bem-sucedida"""
    payload = {
        "machine_id": machine_id,
        "event_type": "SALE",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "data": {
            "slot": code,
            "product_name": name,
            "amount_paid": str(price)
        }
    }
    # Dispara em background para não fazer o cliente esperar no ecrã
    asyncio.create_task(send_telemetry_event(payload))

async def report_stock_alert(machine_id: str, code: str, name: str):
    """Alerta imediatamente a central se um produto esgotar para gerar rota de reposição"""
    payload = {
        "machine_id": machine_id,
        "event_type": "STOCK_ALERT",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "data": {
            "slot": code,
            "product_name": name,
            "status": "OUT_OF_STOCK"
        }
    }
    # Envia imediatamente
    asyncio.create_task(send_telemetry_event(payload))





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
# Usa una imagen oficial de Python
FROM python:3.10-slim

# Define el directorio de trabajo
WORKDIR /app

# Copia los requisitos e instala las dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código
COPY . .

# Expone el puerto (ajusta según lo que use tu app o el servidor)
EXPOSE 8080

# Arranca la aplicación (asegúrate de usar la variable de entorno PORT si el servidor lo pide)
CMD ["python", "app.py"]


docker run -d --device=/dev/ttyUSB0:/dev/ttyUSB0 vending-app


# src/main.py
import asyncio
from hardware.mdb import MDBController

# Instancia o controlador (ajuste a porta conforme o seu hardware)
mdb = MDBController(port='/dev/ttyUSB0')
mdb.conectar()

saldo_atual = 0.0

async def mdb_polling_task():
    """Tarefa em segundo plano que corre junto com o Kivy/Asyncio"""
    global saldo_atual
    while True:
        # Executa de forma assíncrona sem travar o ecrã
        valor_inserido = mdb.verificar_moedas()
        
        if valor_inserido:
            saldo_atual += valor_inserido
            print(f"🪙 Saldo Atualizado: {saldo_atual}€")
            # Aqui aciona a função da sua FSM para atualizar o ecrã do Kivy
            # exemplo: app.root.atualizar_ecran_saldo(saldo_atual)
            
        # Pausa recomendada de 200ms do protocolo MDB
        await asyncio.sleep(0.2)

# No método de inicialização da sua App (onde usa o asyncio.ensure_future):
# asyncio.ensure_future(mdb_polling_task())

docker run -d --device=/dev/ttyUSB0:/dev/ttyUSB0 vending-app



python "Venda da vending.py"


from telemetry import report_sale_to_cloud, report_stock_alert


import asyncio
import aiohttp
import logging
from decimal import Decimal
from datetime import datetime

logger = logging.getLogger("VendingTelemetry")

# URL do servidor central de telemetria (substitua pelo seu endpoint de produção/Fly.io)
TELEMETRY_ENDPOINT = "https://vendingsoftmachines.com"

async def send_telemetry_event(payload: dict) -> bool:
    """
    Envia um payload JSON de forma assíncrona para o servidor central.
    Garante que falhas de rede na nuvem não quebrem o funcionamento físico da máquina.
    """
    try:
        # Timeout curto para evitar que conexões presas consumam memória no Android
        timeout = aiohttp.ClientTimeout(total=5.0)
        
        async with aiohttp.ClientSession(timeout=timeout) as session:
            async with session.post(TELEMETRY_ENDPOINT, json=payload) as response:
                if response.status == 200 or response.status == 201:
                    logger.info(f"📊 Telemetria enviada com sucesso: {payload.get('event_type')}")
                    return True
                else:
                    logger.warning(f"⚠️ Servidor rejeitou telemetria. Status: {response.status}")
                    return False
    except asyncio.TimeoutError:
        logger.error("❌ Timeout ao tentar contactar o servidor de telemetria (Rede lenta).")
        return False
    except Exception as e:
        # Importante: Captura falhas de falta de internet sem deitar a máquina abaixo
        logger.error(f"❌ Falha crítica de rede na telemetria: {e}")
        return False

# Funções auxiliares especializadas que o motor da máquina vai chamar
async def report_sale_to_cloud(machine_id: str, code: str, name: str, price: Decimal):
    """Notifica a nuvem sobre uma venda bem-sucedida"""
    payload = {
        "machine_id": machine_id,
        "event_type": "SALE",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "data": {
            "slot": code,
            "product_name": name,
            "amount_paid": str(price)
        }
    }
    # Dispara em background para não fazer o cliente esperar no ecrã
    asyncio.create_task(send_telemetry_event(payload))

async def report_stock_alert(machine_id: str, code: str, name: str):
    """Alerta imediatamente a central se um produto esgotar para gerar rota de reposição"""
    payload = {
        "machine_id": machine_id,
        "event_type": "STOCK_ALERT",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "data": {
            "slot": code,
            "product_name": name,
            "status": "OUT_OF_STOCK"
        }
    }
    # Envia imediatamente
    asyncio.create_task(send_telemetry_event(payload))

