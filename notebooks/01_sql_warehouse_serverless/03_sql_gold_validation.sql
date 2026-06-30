-- Databricks notebook source

-- MAGIC %md
-- MAGIC # 03 - Gold SQL e Validações
-- MAGIC
-- MAGIC **Objetivo:** gerar tabelas analíticas Gold para consumo em BI.

-- COMMAND ----------

USE training_sql_serverless;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Gold 1: KPIs diários

-- COMMAND ----------

CREATE OR REPLACE TABLE gold_daily_kpis AS
SELECT
  order_date,
  COUNT(DISTINCT order_id) AS orders_count,
  ROUND(SUM(total_amount), 2) AS revenue_total,
  ROUND(AVG(total_amount), 2) AS avg_ticket
FROM silver_orders_enriched
GROUP BY order_date
ORDER BY order_date;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Gold 2: ranking por categoria

-- COMMAND ----------

CREATE OR REPLACE TABLE gold_top_categories AS
WITH category_agg AS (
  SELECT
    product_category,
    COUNT(DISTINCT order_id) AS orders_count,
    ROUND(SUM(total_amount), 2) AS revenue_total,
    ROUND(AVG(total_amount), 2) AS avg_ticket
  FROM silver_orders_enriched
  GROUP BY product_category
),
ranked AS (
  SELECT
    product_category,
    orders_count,
    revenue_total,
    avg_ticket,
    DENSE_RANK() OVER (ORDER BY revenue_total DESC) AS revenue_rank
  FROM category_agg
)
SELECT *
FROM ranked
ORDER BY revenue_rank, product_category;


