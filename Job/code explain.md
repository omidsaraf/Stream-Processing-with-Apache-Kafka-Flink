##### **Job (Web Traffic Data) Setup**

This section describes the **stream processing job** using **PySpark** to process real-time web traffic data from a **Kafka topic** and aggregate it before storing the results in a **PostgreSQL database**.

###### 1. **Initialization of Spark Session:**

```python
spark = SparkSession.builder \
    .appName("Web Traffic Processing") \
    .getOrCreate()
```

This initializes a **SparkSession**, which is the entry point for working with Spark. The application is named `"Web Traffic Processing"`.

###### 2. **Kafka Configuration:**

```python
kafka_bootstrap_servers = os.environ.get('KAFKA_URL', 'localhost:9093')
kafka_topic = os.environ.get('KAFKA_TOPIC', 'web_traffic_topic')
```

Here, the Kafka bootstrap server and Kafka topic are configured via environment variables. If the variables are not set, they default to `localhost:9093` for the Kafka server and `web_traffic_topic` for the Kafka topic.

###### 3. **Define Kafka Data Source:**

```python
kafka_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
    .option("subscribe", kafka_topic) \
    .load()
```

This creates a **streaming DataFrame** that reads messages from the specified Kafka topic (`web_traffic_topic`). The data from Kafka will be read continuously in real-time.

###### 4. **Define Schema for Incoming Data:**

```python
schema = "url STRING, referrer STRING, user_agent STRING, host STRING, ip STRING, headers STRING, event_time STRING"
```

Here, a schema is defined to describe the structure of each Kafka message (with fields like `url`, `referrer`, `user_agent`, `host`, `ip`, `headers`, and `event_time`).

###### 5. **Parsing Kafka Data:**

```python
web_traffic_df = kafka_df.selectExpr("CAST(value AS STRING)") \
    .selectExpr("json_tuple(value, 'url', 'referrer', 'user_agent', 'host', 'ip', 'headers', 'event_time') as (url, referrer, user_agent, host, ip, headers, event_time)") \
    .select("url", "referrer", "user_agent", "host", "ip", "headers", "event_time")
```

This part:
- Converts the Kafka `value` field into a string.
- Extracts fields from the JSON structure of the Kafka message (via `json_tuple`), assigning them to the appropriate column names (`url`, `referrer`, etc.).
- Selects the columns to keep for further processing.

###### 6. **Aggregating Web Traffic:**

```python
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
```

In this step:
- **Watermarking** is applied to the `event_time` field to handle late data. A watermark of 1 minute means that data arriving more than 1 minute after the event time will be ignored.
- The data is **grouped** by:
  - **5-minute sliding windows** based on the `event_time`.
  - **Host** and **referrer**.
- The **count of records (`num_hits`)** for each combination of the window, host, and referrer is calculated.

###### 7. **Output to PostgreSQL:**

```python
aggregated_df.writeStream \
    .foreachBatch(lambda df, epoch_id: df.write.jdbc(url=os.environ.get('POSTGRES_URL'), table='aggregated_web_traffic', mode='append', properties={"user": os.environ.get('POSTGRES_USER'), "password": os.environ.get('POSTGRES_PASSWORD')})) \
    .outputMode("append") \
    .start() \
    .awaitTermination()
```

This part outputs the results of the aggregation to a PostgreSQL database:
- The **`foreachBatch`** function is used to write each micro-batch of data to the `aggregated_web_traffic` table in PostgreSQL. Each batch is written using JDBC.
- The **PostgreSQL connection details** (URL, user, and password) are

 retrieved from environment variables.
- The **output mode** is set to `"append"`, meaning new records will be added to the PostgreSQL table without modifying existing data.
- The job will **continue running indefinitely** until terminated (`awaitTermination`).

---
