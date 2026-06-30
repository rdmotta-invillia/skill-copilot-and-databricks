## 🥈 Etapa 2 - Limpeza e Padronização (Silver SQL)

Agora que a Bronze está pronta, transforme os dados em uma camada Silver confiável.

Abra `notebooks/01_sql_warehouse_serverless/02_sql_cleaning_etl.sql`.

Neste arquivo você precisa implementar a consulta "TODO" para criar a tabela `silver_orders_clean` aplicando as seguintes regras:

### 🎯 O que implementar

- [V] Criar `silver_orders_clean` com:
  - cast de tipos
  - filtro de registros inválidos (`quantity`, `unit_price`, `status`)
  - remoção de duplicados por `order_id` com `row_number()`
  - `total_amount` calculado
- [V] Criar `silver_customers_clean` com:
  - email normalizado (`lower(trim(email))`)
  - `is_valid_email` via regex
- [V] Criar `silver_orders_enriched` com join entre pedidos e clientes
- [ ] Verificar quantos pedidos ficaram sem dados de cliente após o LEFT JOIN.
  - **Objetivo:** medir % de linhas com customer_name nulo e definir um limite aceitável (ex.: < 2%).
- [ ] Validação de integridade do cálculo de valor total
  - **Objetivo:** confirmar se total_amount está consistente com quantity * unit_price. 
- [ ] Validação de regras de domínio (filtros da Silver)
  - **Objetivo:** garantir que as regras aplicadas em silver_orders_clean realmente se mantêm no enriquecido.
- [ ] Validação de unicidade de pedido após deduplicação
  - **Objetivo:** validar se a deduplicação por order_id funcionou.
- [ ] Validação de qualidade cadastral de cliente
  - **Objetivo:** analisar consistência dos atributos de cliente trazidos no enriquecimento.


### ▶️ Como avançar

```bash
git add notebooks/01_sql_warehouse_serverless/02_sql_cleaning_etl.sql
git commit -m "feat: track1 etapa 2 - silver sql etl"
git push origin main
```

> ⚡ O Actions vai postar a etapa de **Gold SQL + validações finais**.
