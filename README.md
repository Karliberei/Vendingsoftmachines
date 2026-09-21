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

