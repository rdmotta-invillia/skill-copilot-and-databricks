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

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Validação Gold: qualidade dos dados
-- MAGIC
-- MAGIC **Objetivo:** consolidar checks críticos de qualidade para consumo analítico.

-- COMMAND ----------

WITH key_nulls AS (
  SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id
  FROM silver_orders_enriched
),
orders_without_customer AS (
  SELECT
    COUNT(*) AS orders_without_customer
  FROM silver_orders_clean o
  LEFT JOIN silver_customers_clean c
    ON o.customer_id = c.customer_id
  WHERE c.customer_id IS NULL
),
email_quality AS (
  SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN COALESCE(is_valid_email, FALSE) = FALSE THEN 1 ELSE 0 END) AS invalid_emails
  FROM silver_customers_clean
)
SELECT
  k.null_order_id,
  k.null_customer_id,
  owc.orders_without_customer,
  eq.total_customers,
  eq.invalid_emails,
  ROUND((eq.invalid_emails * 100.0) / NULLIF(eq.total_customers, 0), 2) AS pct_invalid_emails,
  CASE
    WHEN k.null_order_id = 0
      AND k.null_customer_id = 0
      AND owc.orders_without_customer = 0 THEN 'PASS'
    ELSE 'ALERT'
  END AS validation_status
FROM key_nulls k
CROSS JOIN orders_without_customer owc
CROSS JOIN email_quality eq;


