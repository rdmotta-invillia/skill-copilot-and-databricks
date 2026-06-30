#!/usr/bin/env bash
# .devcontainer/post-create.sh — Executado após criação, com o repositório disponível
set -euo pipefail

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  post-create.sh — Configurando ambiente do treinamento"
echo "══════════════════════════════════════════════════════════════"
echo ""

# ── 1. Criar .env a partir do exemplo ─────────────────────────────────────────
if [ ! -f .env ]; then
  cp .env.example .env
  echo "📝 .env criado — preencha DATABRICKS_HOST e DATABRICKS_TOKEN"
else
  echo "✅ .env já existe."
fi
# Carrega as variáveis do .env na sessão atual (VOLUME_CATALOG, VOLUME_SCHEMA, VOLUME_NAME...)
# shellcheck disable=SC1091
set -a; source .env; set +a
# ── 2. Instalar Databricks CLI (fallback se não veio no Dockerfile) ─────────────
if ! command -v databricks >/dev/null 2>&1; then
  echo "📥 Databricks CLI não encontrado — instalando em ~/bin..."
  mkdir -p ~/bin
  DATABRICKS_RUNTIME_VERSION=1 curl -fsSL \
    https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
  # Garante ~/bin no PATH da sessão atual
  export PATH="$HOME/bin:$PATH"
  # Persiste no bashrc para sessões futuras
  grep -qxF 'export PATH="$HOME/bin:$PATH"' ~/.bashrc \
    || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
  echo "✅ Databricks CLI instalado: $(databricks -v 2>&1 || true)"
else
  echo "✅ Databricks CLI já disponível: $(databricks -v 2>&1 || true)"
fi

# ── 3. Configurar Databricks CLI ──────────────────────────────────────────────
if [ -n "${DATABRICKS_HOST:-}" ] && [ -n "${DATABRICKS_TOKEN:-}" ]; then
  echo "🔧 Configurando Databricks CLI..."
  # Recover from older setup that created ~/.databrickscfg as a directory.
  if [ -d ~/.databrickscfg ]; then
    rm -rf ~/.databrickscfg
  fi
  cat > ~/.databrickscfg << DBCFG
[DEFAULT]
host  = ${DATABRICKS_HOST}
token = ${DATABRICKS_TOKEN}
DBCFG
  echo "✅ Databricks CLI configurado → ${DATABRICKS_HOST}"
else
  echo "⚠️  DATABRICKS_HOST/TOKEN não definidos."
  echo "   Configure em: repo → Settings → Secrets and variables → Codespaces"
fi

# ── 4. Gerar dados de exemplo ─────────────────────────────────────────────────
echo ""
echo "📊 Gerando dados de exemplo..."
python scripts/generate_sample_data.py && echo "✅ Dados gerados em data/raw/" || \
  echo "⚠️  Falha ao gerar dados. Execute: python scripts/generate_sample_data.py"
# ── 4b. Garantir Volume Unity Catalog e fazer upload ───────────────────────────
# Defaults compatíveis com o Makefile (usam vars já carregadas do .env)
VC="${VOLUME_CATALOG:-workspace}"
VS="${VOLUME_SCHEMA:-training}"
VN="${VOLUME_NAME:-raw_files}"
VOLUME_RAW_PATH="/Volumes/${VC}/${VS}/${VN}"

if [ -n "${DATABRICKS_HOST:-}" ] && [ -n "${DATABRICKS_TOKEN:-}" ]; then
  echo ""
  echo "🗄️  Criando schema e volume no Unity Catalog..."

  # Criar schema (ignora erro 409 ALREADY_EXISTS)
  curl -sf -X POST "${DATABRICKS_HOST}/api/2.1/unity-catalog/schemas" \
    -H "Authorization: Bearer ${DATABRICKS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"catalog_name\":\"${VC}\",\"name\":\"${VS}\"}" \
    >/dev/null 2>&1 || true

  # Criar volume gerenciado (ignora erro 409 ALREADY_EXISTS)
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "${DATABRICKS_HOST}/api/2.1/unity-catalog/volumes" \
    -H "Authorization: Bearer ${DATABRICKS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"catalog_name\":\"${VC}\",\"schema_name\":\"${VS}\",\"name\":\"${VN}\",\"volume_type\":\"MANAGED\"}")

  if [ "${HTTP_STATUS}" = "200" ] || [ "${HTTP_STATUS}" = "201" ]; then
    echo "✅ Volume ${VC}.${VS}.${VN} criado"
  elif [ "${HTTP_STATUS}" = "409" ]; then
    echo "ℹ️  Volume ${VC}.${VS}.${VN} já existe"
  else
    echo "⚠️  Não foi possível criar o volume (HTTP ${HTTP_STATUS}) — verifique permissões no Unity Catalog"
  fi

  # Upload dos CSVs para o Volume
  echo ""
  echo "☁️  Fazendo upload dos dados para o Volume..."
  if [ -f data/raw/orders.csv ]; then
    databricks fs mkdirs "dbfs:${VOLUME_RAW_PATH}" 2>/dev/null || true
    databricks fs cp --overwrite data/raw/orders.csv    "dbfs:${VOLUME_RAW_PATH}/orders.csv" \
      && databricks fs cp --overwrite data/raw/customers.csv "dbfs:${VOLUME_RAW_PATH}/customers.csv" \
      && echo "✅ CSVs enviados para dbfs:${VOLUME_RAW_PATH}" \
      || echo "⚠️  Upload falhou — execute 'make upload-data' após configurar as credenciais"
  else
    echo "⚠️  data/raw/orders.csv não encontrado — execute 'make generate-data && make upload-data'"
  fi
else
  echo ""
  echo "⚠️  Credenciais não configuradas — volume e upload serão pulados."
  echo "   Execute após configurar .env: make generate-data && make upload-data"
fi

# ── 5. Verificar PySpark + Delta Lake ────────────────────────────────────────────
echo ""
python3 - <<'PYCHECK'
try:
    import pyspark, delta
    print(f"✅ PySpark {pyspark.__version__} + delta-spark {delta.__version__}")
except ImportError as e:
    print(f"⚠️  {e}")
PYCHECK

# ── 6. Verificar Databricks Connect ─────────────────────────────────────────────
python3 - <<'DBCONNECTCHECK'
try:
  import databricks.connect
  print("✅ Databricks Connect disponível")
except ImportError as e:
  print(f"⚠️  Databricks Connect indisponível: {e}")
DBCONNECTCHECK

# ── 6. Resumo ─────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  🎉 Ambiente pronto! Próximos passos:"
echo ""
echo "  1. Preencha .env com suas credenciais Databricks"
  echo "  2. make upload-data   → envia dados ao Volume Unity Catalog"
echo "  3. Abra os notebooks em notebooks/ e use Ctrl+Alt+I (Copilot)"
echo ""
echo "  Trilhas disponíveis (GitHub Actions → 01-training-start):"
echo "    🥉 track-1-full         → SQL Warehouse Serverless"
echo "══════════════════════════════════════════════════════════════"
echo ""
