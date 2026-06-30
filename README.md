# Treinamento: Databricks + GitHub Copilot no Dia a Dia

## Visão Geral

Este treinamento apresenta a integração entre **Databricks** e **GitHub Copilot**, com foco prático em como essas ferramentas podem acelerar o desenvolvimento de pipelines de dados, otimizar código e aumentar a produtividade dos times de engenharia de dados.

---

## Agenda


### SQL Warehouse Serverless (40 min)
- Setup do SQL Warehouse serverless 2X-Small
- Integração VS Code + Databricks SQL
- Exercício ETL em SQL: extração, limpeza e camada Gold

---

## Estrutura do Repositório

```
databricks-treinner/
├── README.md                          # Este arquivo
├── docs/
│   ├── 01_setup_guide.md              # Guia de setup do ambiente
│   ├── 02_databricks_concepts.md      # Conceitos chave do Databricks
│   └── 03_copilot_tips.md             # Dicas de uso do Copilot
├── notebooks/
│   └── 01_sql_warehouse_serverless/
│       ├── 01_sql_setup_and_extract.sql # Bronze SQL em warehouse serverless
│       ├── 02_sql_cleaning_etl.sql      # Limpeza e ETL Silver em SQL
│       └── 03_sql_gold_validation.sql   # Gold SQL e validações
├── data/
│   ├── raw/                           # Dados brutos de exemplo
│   └── processed/                     # Dados processados
└── scripts/
    └── generate_sample_data.py        # Script para gerar dados de exemplo
```

---

## ▶️ Escolha sua Trilha e Comece Agora

> **Como funciona:** clique em **"Copiar Exercício"** para criar o repositório a partir do template. O primeiro `push` do repositório criado dispara automaticamente o workflow **SQL Warehouse Serverless**, que cria a Issue e atualiza o README com o link do exercício. Cada commit nos notebooks avança automaticamente a Issue para a próxima etapa.

--- 

### 🧪 SQL Warehouse Serverless (Conta Free)
> Execute um ETL completo usando apenas SQL Warehouse serverless 2X-Small.

[![](https://img.shields.io/badge/Copiar%20Exercício-%E2%86%92-1f883d?style=for-the-badge&logo=github&labelColor=197935)](https://github.com/new?template_owner=rdmotta-invillia&template_name=copilot_and_databricks&owner=%40me&name=skill-copilot-and-databricks&visibility=public)

Se o repositório for criado com GitHub Actions habilitado, a trilha começa automaticamente sem etapa manual.

<!-- TRAINING_ISSUE_LINK_START --> 
<!-- TRAINING_ISSUE_LINK_END -->
---  

O Codespace já vem pré-configurado com:
- ☕ Java 11 + PySpark 3.5.1 + Delta Lake (via pip, sem download de binário)
- 🐍 Python 3.12
- 🔧 Databricks CLI
- 🔌 Databricks Connect
- ⚡ GitHub Copilot + Copilot Chat
- 🗄️ Extensão Databricks para VS Code
- 📊 Jupyter Notebook support

### Configurar Credenciais no Codespaces

Antes de abrir o Codespace, configure os secrets em:
**github.com → Settings → Codespaces → New secret**

| Secret | Valor |
|--------|-------|
| `DATABRICKS_HOST` | `https://community.cloud.databricks.com` |
| `DATABRICKS_TOKEN` | Token gerado em Settings → Developer → Access Tokens |
| `DATABRICKS_CLUSTER_ID` | ID do cluster criado no Databricks |

---

## Pré-requisitos (Instalação Local)

Se preferir rodar localmente em vez do Codespaces:

- Conta gratuita no [Databricks Free Edition](https://login.databricks.com/?dbx_source=docs&intent=CE_SIGN_UP)
- VS Code instalado
- Extensão [Databricks para VS Code](https://marketplace.visualstudio.com/items?itemName=databricks.databricks)
- GitHub Copilot (licença ativa ou trial)
- Python 3.12+ e Java 11+

---

## Como Usar Este Repositório

### Via Codespaces (Recomendado)

1. Configure os secrets `DATABRICKS_HOST`, `DATABRICKS_TOKEN` e `DATABRICKS_CLUSTER_ID` antes de abrir no GitHub Codespaces
2. Abra o repositório no GitHub Codespaces (botão acima)
3. O ambiente será configurado automaticamente
4. Ative a conexão com o ambiente Databricks
5. As ações `make generate-data && make upload-data` são geradas automáticamente para preparar os dados
5. Siga o treinamento guiado pela Issue criada pelo workflow.

### Via Instalação Local 
2. Copie `.env.example` para `.env` e preencha com suas credenciais
3. Execute `make setup && make generate-data`
4. Importe os notebooks na ordem indicada pelos módulos
5. Execute cada célula e pratique com o Copilot ativado

---

## Links Úteis

- [Databricks Free Edition](https://docs.databricks.com/aws/en/getting-started/free-edition)
- [Documentação Databricks](https://docs.databricks.com/)
- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
- [Extensão Databricks VS Code](https://docs.databricks.com/dev-tools/vs-code-ext.html)
- [Delta Lake](https://delta.io/)
