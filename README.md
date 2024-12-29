
# Web Traffic Processing with Apache Kafka, PySpark, and PostgreSQL 

**End-to-End Data Engineering Project**

The main goal of this project is to build an **real-time data pipeline** that processes raw web traffic data. The pipeline:
- Consumes and processes real-time web traffic events using **Apache Kafka**.
- Enriches the data with geolocation information via **PySpark**.
- Aggregates and stores the processed data in a **PostgreSQL** database for real-time analytics and reporting.

This project demonstrates the use of **Apache Kafka**, **PySpark**, **PostgreSQL**, and **Docker** to handle, process, and store web traffic data efficiently for analytical purposes.

---

## **Table of Contents**

1. [Project Structure](#project-structure)
2. [Tools and Technologies](#tools-and-technologies)
3. [Required Libraries](#required-libraries)
4. [Job Processing](#job-processing)
   1. [Processing Job Code](#processing-job-code)
   2. [Testing the Processing Job](#testing-the-processing-job)
5. [CI/CD Setup](#cicd-setup)
   1. [GitHub Actions Workflow](#github-actions-workflow)
6. [PostgreSQL Setup](#postgresql-setup)
   1. [SQL DDL Script](#sql-ddl-script)
7. [Environment Configuration](#environment-configuration)
8. [Makefile](#makefile)

---

## **Project Structure**

```plaintext
├── .github/
│   └── workflows/
│       └── ci.yml               # GitHub Actions CI/CD pipeline
├── ddl/
│   └── init.sql                 # SQL script to initialize PostgreSQL table
├── docker-compose.yml           # Docker Compose for services (Flink, PostgreSQL, Kafka)
├── Dockerfile                   # Dockerfile for building PyFlink container
├── libraries.txt                # Python dependencies for local use
├── Makefile                     # Makefile for managing tasks
├── stream.env                   # Environment variables for services
├── job/
│   ├── Processing_job.py        # Flink job script
│   ├── test_processing_job.py   # Pytest file for testing
```

---

## **Tools and Technologies**

This project leverages the following tools and technologies:

- **Apache Kafka**: A distributed streaming platform used to ingest real-time web traffic data.
- **PostgreSQL**: A relational database for storing processed and aggregated web traffic data.
- **Docker**: Containerization tool for running Kafka and PostgreSQL services.
- **Apache Flink**: A stream processing framework used to process and aggregate web traffic data in real time.
- **PySpark**: A Python API for Apache Spark used for distributed data processing and transformations.

---

## **Required Libraries**

To run the Python jobs, the following libraries are required. You can install them via `pip`:

```bash
pip install pyspark requests psycopg2 kafka-python pandas
pip install -r libraries.txt
```

---

## **Setup Guide**

### **Step 1: Clone the repository**:

```bash
git clone https://github.com/yourusername/web-traffic-processing.git
cd web-traffic-processing
```

### **Step 2: Install Libraries**

Run the following command to install the necessary libraries:

```bash
pip install -r libraries.txt
```

### **Step 3: Configure Environment Variables**

Create a `.env` file and specify the environment variables:

```env
HOST_PORT=5432
CONTAINER_PORT=5432

DOCKER_CONTAINER=my-postgres-container
DOCKER_IMAGE=my-postgres-image

PGADMIN_EMAIL=postgres@postgres.com
PGADMIN_PASSWORD=postgres
PGADMIN_PORT=5050

POSTGRES_USER=youruser
POSTGRES_PASSWORD=yourpassword
POSTGRES_DB=web_traffic
POSTGRES_URL=jdbc:postgresql://localhost:5432/web_traffic
JDBC_BASE_URL="jdbc:postgresql://host.docker.internal:5432"

KAFKA_URL=kafka:9093
KAFKA_TOPIC=web_traffic_topic
KAFKA_GROUP=web_traffic_group
IP_CODING_KEY="MAKE AN ACCOUNT AT https://www.ip2location.io/ TO GET KEY"

FLINK_JOBMANAGER_RPC_ADDRESS=jobmanager
FLINK_VERSION=1.16.0
PYTHON_VERSION=3.7.9
```

### **Step 4: Set Up Docker Services**

Start by setting up **Apache Kafka** and **PostgreSQL** services using Docker:

```bash
docker-compose -f docker-compose.yml --env-file stream.env up --build --remove-orphans -d
```

This will start **Apache Kafka**, **Apache Flink**, and **PostgreSQL** in separate containers.

---

## **Check Environments**

### **Docker**

![Docker](https://github.com/user-attachments/assets/b5e1ff83-dc1c-4629-ba75-da2437dd2891)

### **Postgres**

Login to **pgAdmin** and create the sink (target table).

![image](https://github.com/user-attachments/assets/18568f7c-94df-4d24-ae00-5ac2ee76536c)


### **Apache Flink**

Access **Apache Flink** via the UI at [http://localhost:8081/#/overview](http://localhost:8081/#/overview).

![Apache Flink](https://github.com/user-attachments/assets/5019f42e-b66b-4c62-93d4-d87ccb68e29b)

---

## **Running the Jobs**

### **Job (Web Traffic Data) Setup**

This section describes the **stream processing job** using **PySpark** to process real-time web traffic data from a **Kafka topic** and aggregate it before storing the results in a **PostgreSQL database**.

#### 1. **Initialization of Spark Session:**

```python
spark = SparkSession.builder \
    .appName("Web Traffic Processing") \
    .getOrCreate()
```

This initializes a **SparkSession**, which is the entry point for working with Spark. The application is named `"Web Traffic Processing"`.

#### 2. **Kafka Configuration:**

```python
kafka_bootstrap_servers = os.environ.get('KAFKA_URL', 'localhost:9093')
kafka_topic = os.environ.get('KAFKA_TOPIC', 'web_traffic_topic')
```

Here, the Kafka bootstrap server and Kafka topic are configured via environment variables. If the variables are not set, they default to `localhost:9093` for the Kafka server and `web_traffic_topic` for the Kafka topic.

#### 3. **Define Kafka Data Source:**

```python
kafka_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
    .option("subscribe", kafka_topic) \
    .load()
```

This creates a **streaming DataFrame** that reads messages from the specified Kafka topic (`web_traffic_topic`). The data from Kafka will be read continuously in real-time.

#### 4. **Define Schema for Incoming Data:**

```python
schema = "url STRING, referrer STRING, user_agent STRING, host STRING, ip STRING, headers STRING, event_time STRING"
```

Here, a schema is defined to describe the structure of each Kafka message (with fields like `url`, `referrer`, `user_agent`, `host`, `ip`, `headers`, and `event_time`).

#### 5. **Parsing Kafka Data:**

```python
web_traffic_df = kafka_df.selectExpr("CAST(value AS STRING)") \
    .selectExpr("json_tuple(value, 'url', 'referrer', 'user_agent', 'host', 'ip', 'headers', 'event_time') as (url, referrer, user_agent, host, ip, headers, event_time)") \
    .select("url", "referrer", "user_agent", "host", "ip", "headers", "event_time")
```

This part:
- Converts the Kafka `value` field into a string.
- Extracts fields from the JSON structure of the Kafka message (via `json_tuple`), assigning them to the appropriate column names (`url`, `referrer`, etc.).
- Selects the columns to keep for further processing.

#### 6. **Aggregating Web Traffic:**

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

#### 7. **Output to PostgreSQL:**

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

### **How It Works**

To run this job:

```bash
python job/Processing_job.py
```

This job:
- Connects to a **Kafka topic** to stream real-time web traffic data.
- Processes the data by parsing the JSON and performing aggregation based on **host** and **referrer** within **5-minute windows**.
- Writes the aggregated web traffic statistics (the number of hits) into a **PostgreSQL database** in an **append-only** manner.
```

This version is ready for GitHub's markdown rendering and preserves your structure. Let me know if you'd like any additional adjustments!

