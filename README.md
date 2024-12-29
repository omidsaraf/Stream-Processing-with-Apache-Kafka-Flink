
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
9. [Cost Analysis and Pros/Cons of Tools](#Cost-Analysis-and-Pros/Cons-of-Tools)

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

![image](https://github.com/user-attachments/assets/f01d0301-f25f-4c0d-bfb9-27b9d94fa980)


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


### Cost Analysis and Pros/Cons of Tools

```

| **Tool**              | **Cost Analysis**                                                                                                                                                                                                                                        | **Pros**                                                                                                                                                                                                                     | **Cons**                                                                                                                                                                                                                     |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Apache Kafka**       | **Cost**: Kafka itself is **open-source** and free to use. However, running Kafka in a production environment involves costs such as server hosting, storage, bandwidth, and administration. Cloud-managed Kafka services (like Confluent Cloud) have a pricing model based on throughput and storage. | - **Highly scalable** for handling large volumes of real-time data.<br> - **Fault-tolerant** and highly available.<br> - Can be used in both on-premise and cloud environments.<br> - **Open-source** and community-driven. | - Complex to set up and maintain.<br> - Requires managing topics, partitions, and brokers.<br> - Not ideal for low-latency requirements (i.e., can add delays).<br> - Consumes a lot of system resources in large deployments.     |
| **PostgreSQL**         | **Cost**: PostgreSQL is **free and open-source**. The cost comes from infrastructure, such as database hosting, storage, and backup services. Managed services like AWS RDS or Azure Database can add additional costs.                                  | - **Free and open-source**.<br> - Supports **ACID** transactions.<br> - Highly reliable and scalable.<br> - Excellent support for **SQL** and powerful indexing.<br> - Strong community and extensive documentation. | - Performance can degrade as data grows unless properly tuned.<br> - Can be resource-intensive with large datasets.<br> - Scaling horizontally can be complex.<br> - Lacks built-in replication in base installations.         |
| **Apache Flink**       | **Cost**: Open-source. Operational costs include infrastructure for clusters (servers or cloud services), storage, and monitoring tools. Managed services like AWS Kinesis or Azure Stream Analytics can have usage-based pricing.                     | - Highly scalable and fault-tolerant for **stream processing**.<br> - Supports **stateful processing**.<br> - Provides strong **windowing and time-based operations**.<br> - Good for real-time data pipelines.               | - High learning curve for beginners.<br> - Operational overhead to manage and monitor clusters.<br> - Requires a lot of system resources, especially for stateful processing.<br> - Less community support compared to Kafka. |
| **Apache Spark (PySpark)** | **Cost**: **Free and open-source**. Infrastructure costs are related to the environment (e.g., cloud services like AWS EMR, Google Dataproc, or Databricks). Charges typically depend on the number of VMs or clusters and the processing time. | - Powerful for batch and stream processing.<br> - **Scalable** and can handle **large datasets**.<br> - Easy to integrate with **Hadoop** and other big data tools.<br> - Supports **machine learning (MLlib)** and graph processing. | - Requires large hardware clusters for optimal performance.<br> - More complex than other processing engines for simple jobs.<br> - **Memory management** can be tricky.<br> - High resource consumption.                        |
| **Docker**            | **Cost**: **Free** for open-source Docker Engine. Paid versions (Docker Enterprise) cost based on the number of users or nodes. Cloud services like AWS Fargate or Google Kubernetes Engine (GKE) provide container orchestration and have usage-based pricing. | - **Containerization** enables portability across environments.<br> - **Consistent environments** across development, testing, and production.<br> - Simplifies **CI/CD** pipelines.<br> - Works well with cloud platforms. | - Container management can be complex in production.<br> - Security issues with container vulnerabilities.<br> - May need orchestration tools like Kubernetes for large-scale systems.<br> - Requires additional setup and tools. |
| **Kafka Connect**     | **Cost**: **Free** and part of the Kafka ecosystem. If you're using **Confluent Kafka**, there may be a cost for their managed Kafka services. The cost can also come from the infrastructure hosting the connectors (e.g., cloud services). | - Seamlessly integrates with Kafka for **data ingestion**.<br> - Supports **numerous connectors** for popular systems (e.g., JDBC, HDFS, Elasticsearch, etc.).<br> - Reduces the need for writing custom integration code.       | - Can have performance overhead for complex transformations.<br> - Can become complex to manage and scale.<br> - Difficult to monitor and troubleshoot issues in connectors.<br> - Relatively slow when compared to direct ingestion methods. |
| **AWS / GCP / Azure** (Cloud Hosting)  | **Cost**: Usage-based pricing based on compute resources, storage, bandwidth, and additional services (e.g., **Kafka on AWS MSK**, **PostgreSQL on RDS**). Costs vary based on service utilization. | - Provides **managed services**, reducing the need for complex infrastructure setup and maintenance.<br> - Scalability and flexibility in resource allocation.<br> - **Pay-as-you-go** pricing model.                     | - **Costly** at scale, especially for long-term or high-demand workloads.<br> - Can be difficult to estimate and control costs.<br> - Potential **vendor lock-in**.<br> - Dependency on **internet connection** and service reliability. |
| **Pytest**            | **Cost**: **Free and open-source**. No direct cost involved unless used in a paid service or CI/CD pipeline, where infrastructure and CI tools might have associated costs. | - Fast and easy testing framework for Python.<br> - Supports **fixtures** for setup and teardown.<br> - Excellent support for **parallel testing**.<br> - Simple syntax and great documentation.                      | - Not well suited for **non-Python projects**.<br> - May require additional plugins for specific features.<br> - Can be slow with large test suites unless optimized.<br> - Limited support for distributed testing.            |


