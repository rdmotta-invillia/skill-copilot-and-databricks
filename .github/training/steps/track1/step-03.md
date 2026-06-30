## 🥇 Etapa 3 - Gold SQL e KPI Analítico

Com Silver pronta, crie uma camada Gold para consumo em BI.

Abra `notebooks/01_sql_warehouse_serverless/03_sql_gold_validation.sql`.

### 🎯 O que implementar

- [V] Criar `gold_daily_kpis` com:
  - `order_date`
  - quantidade de pedidos
  - receita total
  - ticket médio
- [V] Criar `gold_top_categories` com ranking por receita
- [ ] Criar query de validação de qualidade dos dados:
  - nulos em chaves
  - pedidos sem cliente correspondente
  - percentual de emails inválidos
- [ ] Reconciliação Gold vs Silver (diária)
  - **Objetivo:** provar que a agregação diária da Gold está fiel à Silver.
- [ ] Completude temporal da Gold diária
  - **Objetivo:** encontrar lacunas de datas e dias com KPI zerado inesperado.
- [ ] Consistência do ranking por categoria
  - **Objetivo:** validar se a Gold de ranking mantém a regra correta de ordenação.
- [ ] Qualidade de vínculo cliente e email (agregado para consumo BI)
  - **Objetivo:** transformar validações de qualidade em métricas de negócio por dia.
- [ ] Detecção de anomalia em receita e ticket (controle estatístico)
  - **Objetivo:** criar validação automática de comportamento fora do padrão.

### ▶️ Finalizar trilha

```bash
git add notebooks/01_sql_warehouse_serverless/03_sql_gold_validation.sql
git commit -m "feat: track1 etapa 3 - gold sql concluida"
git push origin main
```

> ⚡ O Actions detecta o commit e fecha a issue da trilha automaticamente.
