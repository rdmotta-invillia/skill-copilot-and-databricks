## 🧭 Bem-vindo a Trilha SQL Serverless

Nesta trilha você vai executar um mini pipeline de dados usando apenas **Databricks SQL Warehouse** em conta free:

```
CSV no Volume Unity Catalog
   ↓
[Bronze SQL] dados brutos + auditoria
   ↓
[Silver SQL] limpeza e padronização
   ↓
[Gold SQL] KPIs analíticos
```

---

## Setup e Integração (faça primeiro)

### 1. Criar SQL Warehouse serverless 2X-Small
- [ ] Acesse seu workspace Databricks (conta free)
- [ ] Vá em **SQL Warehouses**
- [ ] Clique em **Create SQL Warehouse**
- [ ] Configure:
  - **Type:** `Serverless`
  - **Size:** `2X-Small`
  - **Auto Stop:** 10 min
- [ ] Inicie o warehouse e aguarde status **Running**

### 2. Integrar VS Code com Databricks SQL
- [ ] No VS Code, confirme a extensão Databricks instalada
- [ ] Abra Command Palette: `Databricks: Add Connection`
- [ ] Informe `DATABRICKS_HOST` e token pessoal
- [ ] No seletor de compute da extensão, escolha o SQL Warehouse `Serverless`

### 3. Preparar dados de entrada
Execute no terminal do projeto:

```bash
make generate-data
make upload-data
```

Os arquivos serão enviados para:
- `dbfs:/Volumes/workspace/training_sql_serverless/raw_files/orders.csv`
- `dbfs:/Volumes/workspace/training_sql_serverless/raw_files/customers.csv`

---

## 🥉 Etapa 1 - Extração SQL para Bronze

Abra `notebooks/01_sql_warehouse_serverless/01_sql_setup_and_extract.sql` e implemente os TODOs.

Objetivo desta etapa:
- [V] Criar schema SQL da trilha
- [V] Criar o Volume Unity Catalog para os arquivos de entrada
- [V] Ler CSVs do Volume com `read_files`
- [V] Criar tabelas Bronze com colunas de auditoria
- [ ] Validar contagem de registros
- [ ] Reconciliação de volume (origem x bronze)
  - **Objetivo:** garantir que a carga trouxe o mesmo número de linhas esperado da origem.
- [ ] Chaves obrigatórias e duplicidade
  - **Objetivo:** validar qualidade de chave nas tabelas Bronze.
- [ ] Validação de domínio de status
  - **Objetivo:** identificar valores inválidos de status em pedidos.
- [ ] Qualidade temporal de order_date
  - **Objetivo:** garantir coerência em datas de pedidos.
- [ ] Integridade referencial (pedido sem cliente)
  - **Objetivo:** encontrar pedidos com customer_id inexistente na base de clientes.

### Como avancar

```bash
git add .
git commit -m "feat: track1 etapa 1 - extração bronze sql"
git push origin main
``` 
