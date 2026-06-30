# Databricks: Conceitos Chave para o Treinamento

## Arquitetura Lakehouse

```
┌─────────────────────────────────────────────┐
│              Databricks Lakehouse             │
├──────────────┬──────────────┬───────────────┤
│   Bronze     │    Silver    │     Gold      │
│  (Raw Data)  │  (Cleaned)   │  (Analytics)  │
│              │              │               │
│  Ingestão    │  Validação   │  Agregações   │
│  sem schema  │  e schema    │  e KPIs       │
└──────────────┴──────────────┴───────────────┘
         ↓               ↓              ↓
              Delta Lake (formato base)
```

## Componentes Principais

| Componente | Descrição |
|-----------|-----------|
| **Workspace** | Ambiente colaborativo com notebooks, jobs e pipelines |
| **Cluster** | Conjunto de VMs que executa o Apache Spark |
| **Notebook** | Interface interativa com suporte a Python, SQL, R, Scala |
| **DBFS** | Databricks File System — armazenamento distribuído |
| **Delta Lake** | Formato de arquivo com suporte a ACID, versionamento e time travel |
| **Unity Catalog** | Governança centralizada de dados e metadados |
| **Delta Live Tables** | Framework declarativo para pipelines de dados |
| **Databricks SQL** | Motor SQL otimizado para consultas analíticas |

## Formatos de Notebook no Databricks

Notebooks Databricks suportam múltiplas linguagens por célula:

```python
# Célula Python
df = spark.read.csv("/data/vendas.csv", header=True)
```

```sql
-- Célula SQL (com %sql magic)
SELECT * FROM vendas WHERE ano = 2024
```

```
# Célula Markdown (com %md magic)
## Análise de Vendas 2024
```

## Delta Lake: Por que usar?

- **ACID Transactions**: Operações atômicas mesmo em falhas
- **Schema Enforcement**: Rejeita dados que não respeitam o schema
- **Time Travel**: Acesso a versões anteriores dos dados
- **Z-Order**: Índice multidimensional para queries rápidas
- **Auto-Optimize**: Compactação automática de arquivos pequenos

## Comandos Essenciais

```python
# Listar tabelas Delta
display(spark.sql("SHOW TABLES"))

# Ver histórico de versões
spark.sql("DESCRIBE HISTORY nome_tabela").show()

# Time travel
df = spark.read.format("delta").option("versionAsOf", 2).load("/path/tabela")

# Otimizar tabela
spark.sql("OPTIMIZE nome_tabela ZORDER BY (coluna_filtro_principal)")

# Limpeza de versões antigas
spark.sql("VACUUM nome_tabela RETAIN 168 HOURS")
```
