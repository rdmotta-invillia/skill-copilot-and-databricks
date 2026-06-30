# ── Base: Python 3.12 com ferramentas de desenvolvimento ─────────────────────
FROM mcr.microsoft.com/devcontainers/python:3.12-bullseye

# ── Variáveis de ambiente ─────────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/default-java \
    PYSPARK_PYTHON=/usr/local/bin/python3 \
    PYSPARK_DRIVER_PYTHON=/usr/local/bin/python3 \
    SPARK_LOCAL_IP=127.0.0.1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# ── 1. Java 11 (necessário para PySpark) ─────────────────────────────────────
# OpenJDK do Debian: mais rápido que baixar Temurin e suficiente para PySpark
RUN rm -f /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.save 2>/dev/null \
    && apt-get update && apt-get install -y --no-install-recommends \
    default-jdk-headless \
    curl \
    unzip \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── 2. Dependências Python ────────────────────────────────────────────────────
# pyspark + delta-spark já incluem os JARs — sem necessidade de Spark binário
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# ── 3. Databricks CLI ─────────────────────────────────────────────────────────
# Instala de forma idempotente para evitar falha caso o binário já exista.
RUN if command -v databricks >/dev/null 2>&1; then \
            databricks -v; \
        else \
            curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh; \
        fi

# ── 4. Profile do usuário vscode ──────────────────────────────────────────────
USER vscode
WORKDIR /workspaces/databricks-treinner

RUN echo '' >> ~/.bashrc \
    && echo '# ── Databricks Training ──' >> ~/.bashrc \
    && echo 'export SPARK_LOCAL_IP=127.0.0.1' >> ~/.bashrc \
    && echo 'export PYSPARK_PYTHON=/usr/local/bin/python3' >> ~/.bashrc \
    && echo 'alias run-sample-data="python scripts/generate_sample_data.py"' >> ~/.bashrc \
    && echo 'alias dbx="databricks"' >> ~/.bashrc