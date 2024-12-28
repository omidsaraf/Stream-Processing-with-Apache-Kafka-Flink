from pyspark.sql import SparkSession
from pyspark.sql.functions import col, window, count
import os

# Initialize Spark session
spark = SparkSession.builder \
    .appName("Web Traffic Processing") \
    .getOrCreate()

# Set Kafka configurations
kafka_bootstrap_servers = os.environ.get('KAFKA_URL', 'localhost:9093')
kafka_topic = os.environ.get('KAFKA_TOPIC', 'web_traffic_topic')

# Define Kafka data source
kafka_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
    .option("subscribe", kafka_topic) \
    .load()

# Define the schema for incoming data
schema = "url STRING, referrer STRING, user_agent STRING, host STRING, ip STRING, headers STRING, event_time STRING"

# Parse Kafka value and transform into structured data
web_traffic_df = kafka_df.selectExpr("CAST(value AS STRING)").selectExpr("json_tuple(value, 'url', 'referrer', 'user_agent', 'host', 'ip', 'headers', 'event_time') as (url, referrer, user_agent, host, ip, headers, event_time)") \
    .select("url", "referrer", "user_agent", "host", "ip", "headers", "event_time")

# Define aggregation for web traffic by host and referrer
aggregated_df = web_traffic_df \
    .withWatermark("event_time", "1 minute") \
    .groupBy(
        window(col("event_time"), "5 minutes", "5 minutes"),
        col("host"),
        col("referrer")
    ) \
    .agg(
        count("*").alias("num_hits")
    )

# Output aggregated results to Postgres
aggregated_df.writeStream \
    .foreachBatch(lambda df, epoch_id: df.write.jdbc(url=os.environ.get('POSTGRES_URL'), table='aggregated_web_traffic', mode='append', properties={"user": os.environ.get('POSTGRES_USER'), "password": os.environ.get('POSTGRES_PASSWORD')})) \
    .outputMode("append") \
    .start() \
    .awaitTermination()
