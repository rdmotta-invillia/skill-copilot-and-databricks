#!/usr/bin/env bash
# .devcontainer/on-create.sh — Executado UMA vez na criação do container
set -euo pipefail

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   🎓 Databricks + GitHub Copilot Training — Codespaces      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

mkdir -p data/{raw,processed,delta}

echo "✅ Java:   $(java -version 2>&1 | head -1)"
echo "✅ Python: $(python3 --version)"
echo ""
echo "on-create.sh concluído."
