# ════════════════════════════════════════════════════════════════════
# Makefile — Databricks + Copilot Training
# Comandos de conveniência para uso no Codespaces
# ════════════════════════════════════════════════════════════════════

.PHONY: help setup generate-data create-volume upload-data test-spark test lint format clean

# Carrega variáveis do .env se existir
ifneq (,$(wildcard .env))
  include .env
  export
endif

# Defaults para paths do Volume (sobrescritos pelo .env se definidos)
VOLUME_CATALOG      ?= workspace
VOLUME_SCHEMA       ?= training
VOLUME_NAME         ?= raw_files
VOLUME_RAW_PATH     ?= /Volumes/$(VOLUME_CATALOG)/$(VOLUME_SCHEMA)/$(VOLUME_NAME)

help: ## Exibe esta ajuda
	@echo ""
	@echo "  🎓 Databricks + Copilot Training — Comandos disponíveis"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

# ── Setup ─────────────────────────────────────────────────────────────────────

setup: ## Instala dependências e configura o ambiente
	@echo "📦 Instalando dependências Python..."
	python3 -m pip install --quiet -r requirements.txt
	@echo "✅ Setup concluído."

generate-data: ## Gera dados de exemplo em data/raw/
	@echo "📊 Gerando dados de exemplo..."
	python3 scripts/generate_sample_data.py

# ── Databricks ────────────────────────────────────────────────────────────────

create-volume: ## Cria schema e volume no Unity Catalog (idempotente)
	@[ -n "$(DATABRICKS_HOST)" ]  || (echo "❌ DATABRICKS_HOST não definido no .env" && exit 1)
	@[ -n "$(DATABRICKS_TOKEN)" ] || (echo "❌ DATABRICKS_TOKEN não definido no .env" && exit 1)
	@echo "🗄️  Garantindo schema e volume no Unity Catalog..."
	@curl -sf -X POST "$(DATABRICKS_HOST)/api/2.1/unity-catalog/schemas" \
	  -H "Authorization: Bearer $(DATABRICKS_TOKEN)" \
	  -H "Content-Type: application/json" \
	  -d "{\"catalog_name\":\"$(VOLUME_CATALOG)\",\"name\":\"$(VOLUME_SCHEMA)\"}" \
	  >/dev/null 2>&1 || true
	@curl -sf -X POST "$(DATABRICKS_HOST)/api/2.1/unity-catalog/volumes" \
	  -H "Authorization: Bearer $(DATABRICKS_TOKEN)" \
	  -H "Content-Type: application/json" \
	  -d "{\"catalog_name\":\"$(VOLUME_CATALOG)\",\"schema_name\":\"$(VOLUME_SCHEMA)\",\"name\":\"$(VOLUME_NAME)\",\"volume_type\":\"MANAGED\"}" \
	  >/dev/null 2>&1 || true
	@echo "✅ Volume $(VOLUME_CATALOG).$(VOLUME_SCHEMA).$(VOLUME_NAME) pronto"

upload-data: create-volume ## Faz upload dos dados de exemplo para o Volume
	@echo "☁️  Fazendo upload para o Volume..."
	@[ -f data/raw/orders.csv ] || (echo "❌ Execute 'make generate-data' primeiro" && exit 1)
	databricks fs mkdirs dbfs:$(VOLUME_RAW_PATH)
	databricks fs cp --overwrite data/raw/orders.csv    dbfs:$(VOLUME_RAW_PATH)/orders.csv
	databricks fs cp --overwrite data/raw/customers.csv dbfs:$(VOLUME_RAW_PATH)/customers.csv
	@echo "✅ Upload concluído em dbfs:$(VOLUME_RAW_PATH)"

cluster-start: ## Inicia o cluster Databricks
	@[ -n "$(DATABRICKS_CLUSTER_ID)" ] || (echo "❌ DATABRICKS_CLUSTER_ID não definido no .env" && exit 1)
	@echo "🚀 Iniciando cluster $(DATABRICKS_CLUSTER_ID)..."
	databricks clusters start --cluster-id $(DATABRICKS_CLUSTER_ID)
	@echo "✅ Cluster iniciado. Aguarde ficar verde no painel."

cluster-status: ## Verifica o status do cluster Databricks
	@[ -n "$(DATABRICKS_CLUSTER_ID)" ] || (echo "❌ DATABRICKS_CLUSTER_ID não definido no .env" && exit 1)
	databricks clusters get --cluster-id $(DATABRICKS_CLUSTER_ID) | python3 -c \
		"import json,sys; d=json.load(sys.stdin); print(f\"Cluster: {d['cluster_name']} | Estado: {d['state']}\")"

databricks-check: ## Verifica a conexão com o Databricks
	@echo "🔌 Testando conexão com Databricks..."
	databricks clusters list 2>/dev/null && echo "✅ Conexão OK" || echo "❌ Falha. Verifique DATABRICKS_HOST e DATABRICKS_TOKEN"

# ── Spark Local ───────────────────────────────────────────────────────────────

test-spark: ## Testa Spark local (ou Databricks Connect, se instalado)
	@echo "🔥 Testando PySpark + Delta Lake localmente..."
	python3 scripts/test_spark.py

# ── Qualidade de código ───────────────────────────────────────────────────────

lint: ## Verifica qualidade de código com ruff e mypy
	@echo "🔍 Executando linters..."
	ruff check notebooks/ scripts/ --fix
	@echo "✅ Lint concluído."

format: ## Formata código com black e isort
	@echo "🎨 Formatando código..."
	black notebooks/ scripts/ --line-length 88
	isort notebooks/ scripts/ --profile black
	@echo "✅ Formatação concluída."

test: ## Executa testes unitários
	@echo "🧪 Executando testes..."
	pytest tests/ -v --tb=short 2>/dev/null || echo "ℹ️  Sem testes ainda — crie em tests/"

# ── Utilitários ───────────────────────────────────────────────────────────────

clean: ## Remove arquivos temporários e cache
	@echo "🧹 Limpando arquivos temporários..."
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete 2>/dev/null || true
	rm -rf /tmp/spark-warehouse 2>/dev/null || true
	@echo "✅ Limpeza concluída."

env-check: ## Verifica as variáveis de ambiente necessárias
	@echo "🔧 Verificando variáveis de ambiente..."
	@[ -n "$(DATABRICKS_HOST)" ]  && echo "  ✅ DATABRICKS_HOST"  || echo "  ❌ DATABRICKS_HOST não definido"
	@[ -n "$(DATABRICKS_TOKEN)" ] && echo "  ✅ DATABRICKS_TOKEN" || echo "  ❌ DATABRICKS_TOKEN não definido"
	@[ -n "$(DATABRICKS_CLUSTER_ID)" ] && echo "  ✅ DATABRICKS_CLUSTER_ID" || echo "  ⚠️  DATABRICKS_CLUSTER_ID não definido"
	@command -v java >/dev/null        && echo "  ✅ Java: $$(java -version 2>&1 | head -1)" || echo "  ❌ Java não encontrado"
	@command -v databricks >/dev/null  && echo "  ✅ Databricks CLI" || echo "  ❌ Databricks CLI não encontrado"
	@python3 -c "import pyspark; print(f'  ✅ PySpark {pyspark.__version__}')" 2>/dev/null || echo "  ❌ PySpark não instalado"
	@python3 -c "import delta; print(f'  ✅ delta-spark {delta.__version__}')" 2>/dev/null || echo "  ❌ delta-spark não instalado"
