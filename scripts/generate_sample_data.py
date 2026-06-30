#!/usr/bin/env python3
"""
Script para gerar dados de exemplo para o treinamento.
Execute localmente para criar os arquivos CSV que serão enviados ao Volume Unity Catalog.

Uso:
    python scripts/generate_sample_data.py

Os arquivos serão gerados em data/raw/
"""

import csv
import os
import random
from datetime import datetime, timedelta

# Seed para reprodutibilidade
random.seed(42)

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "raw")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Configurações ---
NUM_ORDERS = 10_000
NUM_CUSTOMERS = 500
CATEGORIES = ["eletronicos", "vestuario", "alimentos", "livros", "esportes", "casa"]
REGIONS = ["sudeste", "sul", "nordeste", "centro-oeste", "norte"]
STATUS = ["completed", "cancelled", "pending"]
STATUS_WEIGHTS = [0.75, 0.10, 0.15]

PRODUCTS = {
    "eletronicos": [
        ("Smartphone Samsung", 1500.0),
        ("Notebook Dell", 3500.0),
        ("Tablet iPad", 2800.0),
        ("Fone Bluetooth", 250.0),
        ('Smart TV 55"', 2200.0),
    ],
    "vestuario": [
        ("Camiseta Nike", 120.0),
        ("Calça Jeans Levi's", 280.0),
        ("Tênis Adidas", 450.0),
        ("Jaqueta Columbia", 680.0),
        ("Vestido Zara", 320.0),
    ],
    "alimentos": [
        ("Café Especial 500g", 45.0),
        ("Azeite Extra Virgem", 38.0),
        ("Kit Whey Protein", 189.0),
        ("Vinho Tinto Reserva", 95.0),
        ("Granola Orgânica", 28.0),
    ],
    "livros": [
        ("Clean Code", 85.0),
        ("Designing Data-Intensive Apps", 120.0),
        ("The Pragmatic Programmer", 95.0),
        ("Fundamentals of Data Engineering", 130.0),
        ("Python Crash Course", 75.0),
    ],
    "esportes": [
        ("Bicicleta Speed", 2800.0),
        ("Esteira Elétrica", 3200.0),
        ("Kit Musculação", 850.0),
        ("Raquete Beach Tennis", 420.0),
        ("Prancha de Surf", 1200.0),
    ],
    "casa": [
        ("Aspirador Robô", 1100.0),
        ("Air Fryer XL", 350.0),
        ("Jogo de Cama King", 280.0),
        ("Mesa de Escritório", 750.0),
        ("Luminária LED", 95.0),
    ],
}

start_date = datetime(2023, 1, 1)
end_date = datetime(2024, 12, 31)
date_range = (end_date - start_date).days


def random_date():
    return start_date + timedelta(days=random.randint(0, date_range))


def generate_orders():
    rows = []
    for i in range(NUM_ORDERS):
        order_id = f"ORD-{i+1:06d}"
        customer_id = f"CUST-{random.randint(1, NUM_CUSTOMERS):04d}"
        category = random.choice(CATEGORIES)
        product_name, base_price = random.choice(PRODUCTS[category])
        # Variação de +/- 15% no preço base
        unit_price = round(base_price * random.uniform(0.85, 1.15), 2)
        quantity = random.randint(1, 5)
        order_date = random_date().strftime("%Y-%m-%d %H:%M:%S")
        region = random.choice(REGIONS)
        status = random.choices(STATUS, weights=STATUS_WEIGHTS)[0]

        rows.append(
            {
                "order_id": order_id,
                "customer_id": customer_id,
                "product_category": category,
                "product_name": product_name,
                "quantity": quantity,
                "unit_price": unit_price,
                "order_date": order_date,
                "region": region,
                "status": status,
            }
        )

    # Injeta alguns problemas de qualidade para os exercícios de limpeza
    # Duplicatas
    for _ in range(100):
        rows.append(random.choice(rows[:1000]))

    # Valores negativos/nulos
    for _ in range(50):
        idx = random.randint(0, len(rows) - 1)
        rows[idx]["quantity"] = -1

    random.shuffle(rows)
    return rows


def generate_customers():
    rows = []
    for i in range(NUM_CUSTOMERS):
        customer_id = f"CUST-{i+1:04d}"
        name = f"Cliente {i+1}"
        email = f"cliente{i+1}@email.com"
        city = random.choice(
            [
                "São Paulo",
                "Rio de Janeiro",
                "Belo Horizonte",
                "Curitiba",
                "Porto Alegre",
                "Salvador",
                "Fortaleza",
            ]
        )
        signup_date = (start_date - timedelta(days=random.randint(0, 365))).strftime(
            "%Y-%m-%d"
        )
        segment = random.choice(["B2C", "B2B", "B2B2C"])
        rows.append(
            {
                "customer_id": customer_id,
                "name": name,
                "email": email,
                "city": city,
                "signup_date": signup_date,
                "segment": segment,
            }
        )
    return rows


def write_csv(filename, rows):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)
    print(f"Gerado: {filepath} ({len(rows)} registros)")


if __name__ == "__main__":
    print("Gerando dados de exemplo...")
    write_csv("orders.csv", generate_orders())
    write_csv("customers.csv", generate_customers())
    print("\nConcluído! Faça upload dos arquivos para o Volume:")
    print("  dbfs:/Volumes/workspace/training/raw_files/orders.csv")
    print("  dbfs:/Volumes/workspace/training/raw_files/customers.csv")
    print("\nOu use o comando da CLI Databricks:")
    print(
        "  databricks fs cp data/raw/orders.csv dbfs:/Volumes/workspace/training/raw_files/orders.csv"
    )
    print(
        "  databricks fs cp data/raw/customers.csv dbfs:/Volumes/workspace/training/raw_files/customers.csv"
    )
