-- Databricks notebook source

-- MAGIC %md
-- MAGIC # 01 - Setup e Extração (Bronze SQL)
-- MAGIC
-- MAGIC **Objetivo:** usar SQL Warehouse Serverless (2X-Small) para ler CSVs no Volume Unity Catalog e criar tabelas Bronze.

 -- COMMAND ----------

-- 1) Criar schema da trilha
CREATE SCHEMA IF NOT EXISTS training_sql_serverless;
USE training_sql_serverless;

-- COMMAND ----------

-- 1.1) Criar volume de entrada para os arquivos CSV
CREATE VOLUME IF NOT EXISTS workspace.training_sql_serverless.raw_files;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Extração de pedidos (Bronze)

-- COMMAND ----------

CREATE OR REPLACE TABLE bronze_orders_raw AS
SELECT
  order_id,
  customer_id,
  product_category,
  product_name,
  quantity,
  unit_price,
  order_date,
  region,
  status,
  current_timestamp() AS _ingestion_timestamp,
  input_file_name() AS _source_file
FROM read_files(
  'dbfs:/Volumes/workspace/training_sql_serverless/raw_files/orders.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Extração de clientes (Bronze)

-- COMMAND ----------

CREATE OR REPLACE TABLE bronze_customers_raw AS
SELECT
  customer_id,
  name,
  email,
  city,
  signup_date,
  current_timestamp() AS _ingestion_timestamp,
  'dbfs:/Volumes/workspace/training_sql_serverless/raw_files/customers.csv' AS _source_file
FROM read_files(
  'dbfs:/Volumes/workspace/training_sql_serverless/raw_files/customers.csv',
  format => 'csv',
  header => true,
  inferSchema => true
);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Validação: Reconciliação de volume (origem x bronze)

-- COMMAND ----------

WITH source_counts AS (
  SELECT 'orders' AS dataset, COUNT(*) AS source_row_count
  FROM read_files(
    'dbfs:/Volumes/workspace/training_sql_serverless/raw_files/orders.csv',
    format => 'csv',
    header => true,
    inferSchema => true
  )
  UNION ALL
  SELECT 'customers' AS dataset, COUNT(*) AS source_row_count
  FROM read_files(
    'dbfs:/Volumes/workspace/training_sql_serverless/raw_files/customers.csv',
    format => 'csv',
    header => true,
    inferSchema => true
  )
),
bronze_counts AS (
  SELECT 'orders' AS dataset, COUNT(*) AS bronze_row_count FROM bronze_orders_raw
  UNION ALL
  SELECT 'customers' AS dataset, COUNT(*) AS bronze_row_count FROM bronze_customers_raw
)
SELECT
  s.dataset,
  s.source_row_count,
  b.bronze_row_count,
  (s.source_row_count - b.bronze_row_count) AS row_count_diff,
  CASE
    WHEN s.source_row_count = b.bronze_row_count THEN 'OK'
    ELSE 'MISMATCH'
  END AS reconciliation_status
FROM source_counts s
INNER JOIN bronze_counts b
  ON s.dataset = b.dataset
ORDER BY s.dataset;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Validação: Qualidade de chave (obrigatoriedade e duplicidade)

-- COMMAND ----------

WITH key_quality AS (
  SELECT
    'bronze_orders_raw' AS table_name,
    'order_id' AS key_column,
    SUM(CASE WHEN order_id IS NULL OR TRIM(CAST(order_id AS STRING)) = '' THEN 1 ELSE 0 END) AS missing_key_count,
    (
      SELECT COALESCE(SUM(dup_count), 0)
      FROM (
        SELECT COUNT(*) - 1 AS dup_count
        FROM bronze_orders_raw
        WHERE order_id IS NOT NULL AND TRIM(CAST(order_id AS STRING)) <> ''
        GROUP BY order_id
        HAVING COUNT(*) > 1
      ) d
    ) AS duplicate_key_count,
    COUNT(*) AS total_rows
  FROM bronze_orders_raw

  UNION ALL

  SELECT
    'bronze_customers_raw' AS table_name,
    'customer_id' AS key_column,
    SUM(CASE WHEN customer_id IS NULL OR TRIM(CAST(customer_id AS STRING)) = '' THEN 1 ELSE 0 END) AS missing_key_count,
    (
      SELECT COALESCE(SUM(dup_count), 0)
      FROM (
        SELECT COUNT(*) - 1 AS dup_count
        FROM bronze_customers_raw
        WHERE customer_id IS NOT NULL AND TRIM(CAST(customer_id AS STRING)) <> ''
        GROUP BY customer_id
        HAVING COUNT(*) > 1
      ) d
    ) AS duplicate_key_count,
    COUNT(*) AS total_rows
  FROM bronze_customers_raw
)
SELECT
  table_name,
  key_column,
  total_rows,
  missing_key_count,
  duplicate_key_count,
  (missing_key_count + duplicate_key_count) AS total_key_issues,
  CASE
    WHEN missing_key_count = 0 AND duplicate_key_count = 0 THEN 'OK'
    ELSE 'FAILED'
  END AS key_quality_status
FROM key_quality
ORDER BY table_name;


