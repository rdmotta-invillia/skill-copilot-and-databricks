# Dicas de Uso do GitHub Copilot com Databricks

## Estratégias para Obter Melhores Sugestões

### 1. Comentários como Contexto
O Copilot usa o contexto ao redor para gerar sugestões. Quanto mais descritivo o comentário, melhor a sugestão.

**Pouco contexto (resultado genérico):**
```python
# lê dados
```

**Bom contexto (resultado específico):**
```python
# Lê um arquivo CSV da DBFS com schema inferido, 
# renomeia colunas para snake_case e remove linhas duplicadas
```

---

### 2. Nomeação Descritiva de Variáveis e Funções
O Copilot usa o nome das funções como dica principal:

```python
def normalize_customer_email_column(df: DataFrame) -> DataFrame:
    # Copilot vai sugerir código para normalizar emails
```

---

### 3. Copilot Chat para Código PySpark Complexo
Use `/explain` e `/fix` no Copilot Chat:

- **`/explain`**: Explica o que um trecho de código faz
- **`/fix`**: Corrige erros de compilação ou lógica
- **`/tests`**: Gera testes unitários para o código
- **`/doc`**: Gera documentação (docstrings)

---

### 4. Exemplos de Prompts Eficazes para Databricks

#### Para PySpark:
```
# Crie um DataFrame PySpark que lê dados Parquet do caminho /data/raw/sales/,
# filtra apenas os registros do ano 2024, e aplica um join com a tabela de clientes
# usando customer_id como chave
```

#### Para Delta Lake:
```
# Escreva dados no formato Delta Lake com merge (upsert) baseado na coluna order_id,
# atualizando os campos status e updated_at quando o registro já existir
```

#### Para otimização:
```
# Analise esta query PySpark e sugira otimizações de performance
# considerando particionamento, cache e broadcast join
```

#### Para SQL no Databricks:
```sql
-- Crie uma view materializada que agrega vendas por produto e mês,
-- calculando total de vendas, ticket médio e variação percentual em relação ao mês anterior
```

---

### 5. Padrões de Uso no Dia a Dia

#### Geração de Schema
```python
# Defina o schema Spark para uma tabela de pedidos de e-commerce com:
# order_id (string), customer_id (string), order_date (timestamp),
# items (array de structs com product_id e quantity), total_amount (decimal 10,2)
```

#### Transformações Complexas
```python
# Explode a coluna items, calcule o subtotal por item (quantity * unit_price),
# e pivote os dados por categoria de produto
```

#### Testes com PyTest
```python
# Gere testes unitários para a função transform_sales_data
# usando mocks do SparkSession e verificando o schema de saída
```

---

### 6. Limitações a Conhecer

- O Copilot não tem acesso ao seu schema real do Databricks — forneça detalhes nos comentários
- Para APIs muito recentes do Databricks (ex: serverless), as sugestões podem estar desatualizadas
- Sempre revise código de segurança (credenciais, permissões)
- O Copilot pode sugerir APIs deprecated — verifique a documentação oficial

---

### 7. Integração Copilot + Databricks Extension no VS Code

Com a extensão Databricks ativa, você pode:
1. Editar notebooks `.py` no VS Code com Copilot ativo
2. Sincronizar automaticamente com o workspace Databricks
3. Rodar células diretamente do VS Code
4. Ver outputs sem abrir o browser

**Fluxo recomendado:**
```
VS Code (editar com Copilot) → Sync automático → Databricks (executar) → VS Code (ver resultado)
```
