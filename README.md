# Vendingsoftmachines 🪙

> Software para gestão e controlo de máquinas de venda automática (Vending Machines) a nível global.

Este repositório contém a lógica estruturada para o funcionamento autónomo de uma máquina de venda, gerindo a inserção de moedas, seleção de produtos, controlo de stock e cálculo automático de trocos.

---

## 📂 Estrutura dos Ficheiros

Atualmente, o projeto está dividido nos seguintes ficheiros principais:

* 📜 **`README.md`**: Este ficheiro, contendo as instruções, documentação e visão geral do projeto.
* 🐍 **`Venda da vending`**: Script em Python que roda o ecrã/painel da máquina em loop contínuo (`while True`). Permite simular no computador as compras, acumular moedas de Euro e acionar o botão de cancelamento/devolução.
* 📂 **`Vending`**: Estrutura base destinada à implementação da lógica física (C++/Arduino) para controlo de relés, motores e comunicação com leitores de moedas.
* 🗃️ **`Index`**: Ficheiro de indexação e registo do projeto.

---

## 🚀 Funcionalidades da Lógica Base

O software foi desenvolvido seguindo o modelo de uma **Máquina de Estados Finitos (FSM)**:
1. **Modo de Espera:** Aguarda moedas ou a digitação de códigos.
2. **Validação de Saldo:** Soma apenas moedas válidas e atualiza o ecrã em tempo real.
3. **Verificação Dupla:** Antes de libertar o item, valida se o código existe, se há stock e se o saldo é suficiente.
4. **Troco Dinâmico:** Calcula e liberta o dinheiro extra após a rotação do motor da espiral.
5. **Segurança de Cancelamento:** Devolve 100% do saldo acumulado se o botão de devolução for premido.

---


## 🛠️ Próximas Implementações
* [ ] Adicionar suporte ao protocolo MDB (Multi-Drop Bus) para moedeiros industriais.
* [x] Criar um sistema automático de faturação que exporta as vendas diárias para um ficheiro .csv. (Concluído no ficheiro 'Venda da vending' ✅)

* [ ] ## 🚀 Como Executar o Simulador Python

Para testar a lógica da máquina de estados no seu computador, siga os passos abaixo:

### 1. Pré-requisitos
Certifique-se de que tem o **Python 3** instalado no seu computador. Pode descarregá-lo em [python.org](https://python.org).

### 2. Instalação
1. Descarregue o código fonte da última [Release](https://github.com).
2. Extraia o ficheiro `.zip` para uma pasta à sua escolha.
3. Abra o **Terminal** (Linux/Mac) ou **Prompt de Comando/PowerShell** (Windows) e navegue até à pasta extraída:
   ```bash
   cd Caminho/Para/A/Pasta/Vendingsoftmachines
   ```

### 3. Execução
Execute o script principal utilizando o comando correspondente ao seu sistema operativo:

* **Windows:**
  ```cmd
  python "Venda da vending.py"
  ```
* **Linux / macOS:**
  ```bash
  python3 "Venda da vending.py"
  ```

O simulador irá iniciar um loop contínuo (painel interativo) no seu terminal, onde poderá testar a inserção de moedas, seleção de produtos e faturação.


## 📱 Arquitetura da Aplicação Móvel (Android Engine)

O ecossistema foi expandido para suportar uma interface gráfica nativa em dispositivos Android utilizando o framework **Kivy**, totalmente integrado com o loop de eventos assíncronos do Python (`asyncio`).

### 🔬 Diferenciais de Engenharia da App:
- **UI Não Bloqueante:** A interface visual (ecrã e botões) corre de forma independente das operações de hardware e rede, garantindo 0% de travamentos (*freezes*).
- **Concorrência Pura:** O método `asyncio.ensure_future` acopla as corrotinas de inserção de saldo e despacho de produtos diretamente ao clock de renderização gráfica.
- **Pronto para Android Industrial:** Estrutura otimizada para ser compilada via Buildozer para ecrãs táteis de máquinas de vending modernas.

### 📲 Como testar a App no Android:
1. Instale o **Pydroid 3** a partir da Google Play Store.
2. No menu Pip do Pydroid 3, instale a biblioteca `kivy`.
3. Copie o código do ficheiro `main.py` do repositório, cole-o no Pydroid 3 e clique em **Executar (Play)**.

## 🛒 Vending Machine Software

> **Looking for Vending Machine software? Buy it from me!**
> 📩 Contact: [vendingsoftmachines@outlook.pt](mailto:vendingsoftmachines@outlook.pt)

