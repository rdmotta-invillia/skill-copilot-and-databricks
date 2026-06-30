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


