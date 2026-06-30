import pyspark
import os
import tempfile


def _run_remote_databricks_connect() -> bool:
    try:
        from databricks.connect import DatabricksSession
    except ImportError:
        return False

    host = os.getenv('DATABRICKS_HOST')
    token = os.getenv('DATABRICKS_TOKEN')
    cluster_id = os.getenv('DATABRICKS_CLUSTER_ID')

    if not (host and token and cluster_id):
        print('⚠️  Databricks Connect detectado, mas faltam DATABRICKS_HOST/TOKEN/CLUSTER_ID.')
        print('ℹ️  Defina essas variáveis para validar sessão remota no cluster.')
        return True

    spark = (
        DatabricksSession.builder
        .host(host)
        .token(token)
        .clusterId(cluster_id)
        .getOrCreate()
    )

    df = spark.range(100)
    print(f'✅ Databricks Connect OK — {df.count()} registros remotos')
    spark.stop()
    print('✅ Teste concluído!')
    return True


def _run_local_pyspark_delta() -> None:
    from pyspark.sql import SparkSession
    from delta import configure_spark_with_delta_pip

    spark_builder = (
        SparkSession.builder
        .appName('training-test')
        .config('spark.driver.memory', '1g')
        .config('spark.sql.extensions', 'io.delta.sql.DeltaSparkSessionExtension')
        .config('spark.sql.catalog.spark_catalog', 'org.apache.spark.sql.delta.catalog.DeltaCatalog')
        .master('local[2]')
    )

    spark = configure_spark_with_delta_pip(spark_builder).getOrCreate()
    spark.sparkContext.setLogLevel('ERROR')

    df = spark.range(100)
    print(f'✅ PySpark {pyspark.__version__} OK — {df.count()} registros')

    with tempfile.TemporaryDirectory() as tmp:
        df.write.format('delta').mode('overwrite').save(tmp)
        df2 = spark.read.format('delta').load(tmp)
        print(f'✅ Delta Lake OK — {df2.count()} registros')

    spark.stop()
    print('✅ Teste concluído!')


if not _run_remote_databricks_connect():
    _run_local_pyspark_delta()
