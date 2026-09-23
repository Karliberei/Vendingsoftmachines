from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from datetime import datetime
import sqlite3

app = FastAPI(title="Painel do Operador - Vending Management")

# Configuração Inicial da Base de Dados
def init_db():
    conn = sqlite3.connect("vending_operator.db")
    cursor = conn.cursor()
    # Tabela de Stocks
    cursor.execute('''CREATE TABLE IF NOT EXISTS stock (
                        id TEXT PRIMARY KEY, nome TEXT, quantidade INTEGER, preco_custo REAL, preco_venda REAL)''')
    # Tabela de Vendas e Faturação
    cursor.execute('''CREATE TABLE IF NOT EXISTS vendas (
                        id INTEGER PRIMARY KEY AUTOINCREMENT, produto_id TEXT, data TEXT, valor_pago REAL, lucro REAL)''')
    conn.commit()
    conn.close()

init_db()

class VendaSchema(BaseModel):
    produto_id: str
    valor_pago: float

# 1. Enviar venda da máquina para o servidor
@app.post("/api/venda")
def registar_venda(venda: VendaSchema):
    conn = sqlite3.connect("vending_operator.db")
    cursor = conn.cursor()
    
    # Verificar produto e stock
    cursor.execute("SELECT quantidade, preco_custo, preco_venda FROM stock WHERE id = ?", (venda.produto_id,))
    produto = cursor.fetchone()
    
    if not produto or produto[0] <= 0:
        conn.close()
        raise HTTPException(status_code=400, detail="Produto sem stock ou não registado")
    
    novo_stock = produto[0] - 1
    lucro = produto[2] - produto[1]
    
    # Atualizar Stock
    cursor.execute("UPDATE stock SET quantidade = ? WHERE id = ?", (novo_stock, venda.produto_id))
    # Registar Venda (Faturação)
    cursor.execute("INSERT INTO vendas (produto_id, data, valor_pago, lucro) VALUES (?, ?, ?, ?)",
                   (venda.produto_id, datetime.now().strftime("%Y-%m-%d %H:%M:%S"), venda.valor_pago, lucro))
    
    conn.commit()
    conn.close()
    return {"status": "sucesso", "mensagem": "Venda processada e stock atualizado"}

# 2. Painel de Controlo do Operador (Acedido pelo Telemóvel)
@app.get("/operador/dashboard")
def obter_dashboard(data_inicio: str = None, data_fim: str = None):
    conn = sqlite3.connect("vending_operator.db")
    cursor = conn.cursor()
    
    # Filtro de datas para faturação diária
    query = "SELECT SUM(valor_pago), SUM(lucro), COUNT(id) FROM vendas"
    params = ()
    if data_inicio and data_fim:
        query += " WHERE data BETWEEN ? AND ?"
        params = (data_inicio + " 00:00:00", data_fim + " 23:59:59")
        
    cursor.execute(query, params)
    faturacao, lucro_total, total_vendas = cursor.fetchone()
    
    # Alertas de Reposição de Stock (Abaixo de 3 unidades)
    cursor.execute("SELECT id, nome, quantidade FROM stock WHERE quantidade < 3")
    alertas_stock = [{"id": r[0], "nome": r[1], "quantidade": r[2]} for r in cursor.fetchall()]
    
    conn.close()
    return {
        "periodo": f"{data_inicio} a {data_fim}" if data_inicio else "Total Acumulado",
        "faturacao_bruta": faturacao or 0.0,
        "lucro_liquido": lucro_total or 0.0,
        "vendas_efetuadas": total_vendas or 0,
        "alertas_reposicao": alertas_stock,
        "exportar_fisco_saf_t": "Simulação de ficheiro XML/SAFT-PT pronto para exportação."
    }
