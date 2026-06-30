#!/usr/bin/env python3
import sys

# Mapeamento: trilha → [(padrão de arquivo, próxima etapa)]
TRACK_TRIGGERS: dict[str, list[tuple[str, str]]] = {
    "track-1-full": [
        ("notebooks/01_sql_warehouse_serverless/01_sql_setup_and_extract", "02"),
        ("notebooks/01_sql_warehouse_serverless/02_sql_cleaning_etl", "03"),
        ("notebooks/01_sql_warehouse_serverless/03_sql_gold_validation", "04"),
    ],
}


def detect_next_step(track: str, changed_files: list[str]) -> str:
    triggers = TRACK_TRIGGERS.get(track, [])
    for pattern, next_step in triggers:
        if any(pattern in f for f in changed_files):
            return next_step
    return "none"


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("next_step=none")
        sys.exit(0)

    track = sys.argv[1]
    files = sys.argv[2].split()
    result = detect_next_step(track, files)
    print(f"next_step={result}")
