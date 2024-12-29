
# Web Traffic Processing with Apache Kafka, PySpark, and PostgreSQL 

**End-to-End Data Engineering Project**

The main goal of this project is to build an **real-time data pipeline** that processes raw web traffic data. The pipeline:
- Consumes and processes real-time web traffic events using **Apache Kafka**.
- Enriches the data with geolocation information via **PySpark**.
- Aggregates and stores the processed data in a **PostgreSQL** database for real-time analytics and reporting.

This project demonstrates the use of **Apache Kafka**, **PySpark**, **PostgreSQL**, and **Docker** to handle, process, and store web traffic data efficiently for analytical purposes.

---

## **Table of Contents**

1. [Overview](#overview)
2. [Tools and Technologies](#tools-and-technologies)
3. [System Requirements](#system-requirements)
4. [Libraries Required](#libraries-required)
5. [Project Structure](#project-structure)
6. [Setup Guide](#setup-guide)
   - [Step 1: Set Up Docker Services](#step-1-set-up-docker-services)
   - [Step 2: Configure Environment Variables](#step-2-configure-environment-variables)
7. [Running the Jobs](#running-the-jobs)
   - [Start Job](#start-job)
   - [Aggregation Job](#aggregation-job)
8. [How It Works](#how-it-works)
---

## **Overview**

The goal of this project is to simulate the end-to-end processing of web traffic data. consume and Processes real-time web traffic events with **Apache Kafka** via **Apache Flink**, enriches it with  geolocation information by **PySpark**, and stores it in **PostgreSQL**. 

---

## **Tools and Technologies**

This project leverages the following tools and technologies:

- **Apache Kafka**: A distributed streaming platform used to ingest real-time web traffic data.
- **PostgreSQL**: A relational database for storing processed and aggregated web traffic data.
- **Docker**: Containerization tool for running Kafka and PostgreSQL services.
- **Apache Flink**: 
- **PySpark**: A Python API for Apache Spark used for distributed data processing and transformations.

---

## **Libraries Required**

To run the Python jobs, the following libraries are required. You can install them via `pip`:

```bash
pip install pyspark requests psycopg2 kafka-python pandas
pip install -r Libraries.md
```

## **Project Structure**


```plaintext
.
├── docker-compose.yml           # Docker Compose configuration for Kafka and PostgreSQL
├── Dockefile             
├── job/
│   ├── Processing_job.py       # Python job to process web traffic data
├── libraries.txt               # Python dependencies file
└── stream.env                  # Environment variables for Kafka/Flink/PostgreSQL connections
├── MakeFile            
```
![image](https://github.com/user-attachments/assets/67421169-ab00-4b5c-92a4-5a75fa6d6d77)

---

## **Setup Guide**

Follow these steps to set up and run the project locally.

### **Step 1: Clone the repository**:

```bash
git clone https://github.com/yourusername/web-traffic-processing.git
cd web-traffic-processing

````
### **Step 2: Install Libraries**

Running `pip install -r libraries.txt` will install them.


### **Step 3: Configure Environment Variables**

Create a `.env` file and specify the environment variabless:

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

Start by setting up **Apache Kafka** and **PostgreSQL** services using Docker.

```bash
docker compose stream-env.env up --build --remove-orphans  -d
````

```bash
docker-compose up --build
````


This will start **Apache Kafka**, **Apache Flink** and **PostgreSQL** in separate containers.


## **Check Environments**

### **Docker**
![image](https://github.com/user-attachments/assets/b5e1ff83-dc1c-4629-ba75-da2437dd2891)

### **Postgres**
login to pgadmin and create sink (target table)
![image](https://github.com/user-attachments/assets/51ad5abc-f5f1-4f59-bd88-f4a10ab86701)

### **Apache Flink**
http://localhost:8081/#/overview
![image](https://github.com/user-attachments/assets/5019f42e-b66b-4c62-93d4-d87ccb68e29b)


## **Running the Jobs**

### **Job (Web Traffic Data) Setup**

**stream processing job** using **PySpark** to process real-time web traffic data from a **Kafka topic** and aggregate it before storing the results in a **PostgreSQL database**. Below is a breakdown of what each part of the code is doing:

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
  Here, the Kafka bootstrap server and Kafka topic are configured via environment variables. If the variables are not set, it defaults to `localhost:9093` for the Kafka server and `web_traffic_topic` for the Kafka topic.

#### 3. **Define Kafka Data Source:**
   ```python
   kafka_df = spark.readStream \
       .format("kafka") \
       .option("kafka.bootstrap.servers", kafka_bootstrap_servers) \
       .option("subscribe", kafka_topic) \
       .load()
   ```
   This creates a **streaming DataFrame** that reads messages from the specified Kafka topic (`web_traffic_topic`). The data from Kafka will be read continuously in real-time.

### 4. **Define Schema for Incoming Data:**
   ```python
   schema = "url STRING, referrer STRING, user_agent STRING, host STRING, ip STRING, headers STRING, event_time STRING"
   ```
   Here, a schema is defined to describe the structure of each Kafka message (with fields like `url`, `referrer`, `user_agent`, `host`, `ip`, `headers`, and `event_time`).

### 5. **Parsing Kafka Data:**
   ```python
   web_traffic_df = kafka_df.selectExpr("CAST(value AS STRING)") \
       .selectExpr("json_tuple(value, 'url', 'referrer', 'user_agent', 'host', 'ip', 'headers', 'event_time') as (url, referrer, user_agent, host, ip, headers, event_time)") \
       .select("url", "referrer", "user_agent", "host", "ip", "headers", "event_time")
   ```
   This part:
   - Converts the Kafka `value` field into a string.
   - Extracts fields from the JSON structure of the Kafka message (via `json_tuple`), assigning them to the appropriate column names (`url`, `referrer`, etc.).
   - Selects the columns to keep for further processing.

### 6. **Aggregating Web Traffic:**
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

### 7. **Output to PostgreSQL:**
   ```python
   aggregated_df.writeStream \
       .foreachBatch(lambda df, epoch_id: df.write.jdbc(url=os.environ.get('POSTGRES_URL'), table='aggregated_web_traffic', mode='append', properties={"user": os.environ.get('POSTGRES_USER'), "password": os.environ.get('POSTGRES_PASSWORD')})) \
       .outputMode("append") \
       .start() \
       .awaitTermination()
   ```
   This part outputs the results of the aggregation to a PostgreSQL database:
   - The **`foreachBatch`** function is used to write each micro-batch of data to the `aggregated_web_traffic` table in PostgreSQL. Each batch is written using JDBC.
   - The **PostgreSQL connection details** (URL, user, and password) are retrieved from environment variables.
   - The **output mode** is set to `"append"`, which means new records will be added to the PostgreSQL table without modifying existing data.
   - The job will **continue running indefinitely** until terminated (`awaitTermination`).


### **How It Works**

To run this job:

```bash
python job/Processing_job.py
```
![image](https://github.com/user-attachments/assets/2baf1f40-bd52-40e3-a8d8-6c60741e73be)

- It connects to a **Kafka topic** to stream real-time web traffic data.
- It processes the data by parsing the JSON and performing aggregation based on **host** and **referrer** within **5-minute windows**.
- It writes the aggregated web traffic statistics (the number of hits) into a **PostgreSQL database** in an **append-only** manner.



