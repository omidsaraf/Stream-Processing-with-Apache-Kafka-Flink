
## Real Time Data Processing (Apache Kafka, PySpark, and PostgreSQL)

**Github Traffic Processing- Real Time Data Engineering Project**

![image](https://github.com/user-attachments/assets/1d0732c3-01b2-473f-b925-4b3a156d00e6)


The main goal of this project is to build an **real-time data pipeline** that processes raw web traffic data. The pipeline:
- Consumes and processes real-time web traffic events using **Apache Kafka**.
- Enriches the data with geolocation information via **PySpark**.
- Aggregates and stores the processed data in a **PostgreSQL** database for real-time analytics and reporting.

This project demonstrates the use of **Apache Kafka**, **PySpark**, **PostgreSQL**, and **Docker** to handle, process, and store Github traffic data efficiently for analytical purposes.

---
#### **Table of Contents**

1. [Project Structure](#project-structure)
2. [Workflow and Layers](#workflow-and-layers)
3. [Tools and Technologies](#tools-and-technologies)
4. [Required Libraries](#required-libraries)
5. [Job Processing](#job-processing)
   1. [Processing Job Code](#processing-job-code)
   2. [Testing the Processing Job](#testing-the-processing-job)
6. [CI/CD Setup](#cicd-setup)
7. [PostgreSQL Setup](#postgresql-setup)
8. [Dependencies](#dependencies)
9. [Environment Configuration](#environment-configuration)
10. [Makefile](#makefile)
11. [How It Works](#how-it-works)
12. [Explortory Analysis](#Explortory-Analysis)
13. [Cost Analysis](#cost-analysis)

---

#### **Project Structure**

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
![image](https://github.com/user-attachments/assets/a78f49a4-e93e-47da-938d-0a22fed3accf)

------------

#### **Workflow and Layers**


| **Layer**                | **Storage**    | **Pipeline**                         | **Process**                                                                                  | **Cluster**                | **Cluster Manager**                                  |
|--------------------------|----------------|--------------------------------------|----------------------------------------------------------------------------------------------|----------------------------|------------------------------------------------------|
| **Data Ingestion**        | Kafka Topics   | Web Servers, Kafka Producers         | Collect data from web servers, send to Kafka Topics                                          | Kafka Cluster              | Zookeeper                                             |
| **Data Processing**       | Memory         | Kafka Topics, Spark Streaming        | Read data from Kafka Topics, process data with Spark Streaming, orchestrate with Flink         | Spark Cluster, Flink Cluster| Flink Job Manager, Flink Task Manager, Spark Driver  |
| **Data Aggregation**      | Memory         | Flink, Data Windows                  | Aggregate data by host and referrer using DataFrame operations                                | Spark Cluster, Flink Cluster| Flink Job Manager, Flink Task Manager, Spark Driver  |
| **Data Storage**          | PostgreSQL     | Flink Output, Data Tables            | Store aggregated data in PostgreSQL tables, make data queryable                               | PostgreSQL Nodes           | N/A (PostgreSQL manages its own data)                |
| **CI/CD & Development**   | GitHub Repos   | Build, Test, Deploy                  | Automate build, test, and deploy using GitHub Actions, use Docker for consistent environments, development in VS Code | Development and CI/CD environments | N/A (Managed by GitHub Actions and Docker orchestration) |

------------

---

#### **Tools and Technologies**

| **Tool/Technology**      | **Purpose**                                      | **Components**                                  | **Cluster Manager**         |
|--------------------------|--------------------------------------------------|-------------------------------------------------|-----------------------------|
| **Apache Kafka**          | Real-time data streaming and processing.         | Kafka Producers, Kafka Topics, Kafka Brokers    | Zookeeper                   |
| **Spark Streaming**       | Real-time data processing.                       | Spark Jobs, Spark Functions                     | Spark Driver                |
| **Apache Flink**          | Stream processing and orchestration.             | Flink Job Manager, Flink Task Manager           | N/A                         |
| **PySpark**               | Data aggregation and processing.                 | DataFrame operations, Data Windows              | N/A                         |
| **PostgreSQL**            | Data storage and management.                     | PostgreSQL Database, Data Tables                | N/A                         |
| **GitHub**                | Continuous Integration and Continuous Deployment (CI/CD). | Automate build, test, and deploy pipelines      | N/A                         |
| **Docker**                | Containerization for consistent environments.    | Docker Containers                               | N/A                         |
| **VS Code**               | Development environment.                         | Integrated development and testing environment, supports coding, debugging, and version control | N/A                         |

---

#### **Required Libraries**

To run the Python jobs, the following libraries are required. You can install them via `pip`:

```bash
pip install pyspark requests psycopg2 kafka-python pandas
pip install -r libraries.txt
```

---

#### **Setup Guide**

##### **Step 1: Clone the repository**:

```bash
git clone https://github.com/yourusername/web-traffic-processing.git
cd web-traffic-processing
```

##### **Step 2: Install Libraries**

Run the following command to install the necessary libraries:

```bash
pip install -r libraries.txt
```

##### **Step 3: Configure Environment Variables**

Create a `.env` file and specify the environment variables:

[stream.env](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/stream.env)

##### **Step 4: Set Up Docker Services**

Start by setting up **Apache Kafka** and **PostgreSQL** services using Docker:

```bash
docker-compose -f docker-compose.yml --env-file stream.env up --build --remove-orphans -d
```

This will start **Apache Kafka**, **Apache Flink**, and **PostgreSQL** in separate containers.

---

#### **Check Environments**

##### **Docker**

![Docker](https://github.com/user-attachments/assets/b5e1ff83-dc1c-4629-ba75-da2437dd2891)

##### **Postgres**

Login to **pgAdmin** and create the sink (target table).

![image](https://github.com/user-attachments/assets/18568f7c-94df-4d24-ae00-5ac2ee76536c)


##### **Apache Flink**

Access **Apache Flink** via the UI at [http://localhost:8081/#/overview](http://localhost:8081/#/overview).

![image](https://github.com/user-attachments/assets/f01d0301-f25f-4c0d-bfb9-27b9d94fa980)


---

#### **Running the Jobs**

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

##### **How It Works**

To run this job:

```bash
python job/Processing_job.py
```

This job:
- Connects to a **Kafka topic** to stream real-time web traffic data.
- Processes the data by parsing the JSON and performing aggregation based on **host** and **referrer** within **5-minute windows**.
- Writes the aggregated web traffic statistics (the number of hits) into a **PostgreSQL database** in an **append-only** manner.

------
#### Exploratory Analysis
[Code Space](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/exploratory%20analysis/countribution%20analysis.sql)

##### Goal of the Code
The goal of the SQL code is to analyze web traffic data from the aggregated_web_traffic table. It specifically aims to:

- Calculate daily interactions by city and country.

- Determine daily interactions for each country.

- Calculate total global interactions.

- Provide detailed insights into contributions and percentages for the top 10 records based on city interactions.

- Predict changes in interactions using previous and next day contributions.


Top 10 Records

| City Contribution                           | Country Contribution                                   | Percentage Contribution | Previous Day Contribution | Next Day Contribution | Forecasted Change |
|---------------------------------------------|--------------------------------------------------------|-------------------------|---------------------------|-----------------------|-------------------|
| {"city": "Sydney", "count": 1500}           | {"country": "Australia", "total_count": 3000}          | 15.00%                  | 1400                      | 1600                  | 200               |
| {"city": "Melbourne", "count": 1200}        | {"country": "Australia", "total_count": 3000}          | 12.00%                  | 1150                      | 1250                  | 100               |
| {"city": "Brisbane", "count": 1000}         | {"country": "Australia", "total_count": 3000}          | 10.00%                  | 1050                      | 1100                  | 50                |
| {"city": "New York", "count": 900}          | {"country": "USA", "total_count": 2000}                | 9.00%                   | 800                       | 950                   | 150               |
| {"city": "Los Angeles", "count": 800}       | {"country": "USA", "total_count": 2000}                | 8.00%                   | 750                       | 850                   | 100               |
| {"city": "Toronto", "count": 750}           | {"country": "Canada", "total_count": 1500}             | 7.50%                   | 700                       | 800                   | 100               |
| {"city": "Vancouver", "count": 700}         | {"country": "Canada", "total_count": 1500}             | 7.00%                   | 650                       | 750                   | 100               |
| {"city": "San Francisco", "count": 650}     | {"country": "USA", "total_count": 2000}                | 6.50%                   | 600                       | 700                   | 100               |
| {"city": "Chicago", "count": 600}           | {"country": "USA", "total_count": 2000}                | 6.00%                   | 550                       | 650                   | 100               |
| {"city": "Montreal", "count": 550}          | {"country": "Canada", "total_count": 1500}             | 5.50%                   | 500                       | 600                   | 100               |


###### City Contributions

Sydney         1500 | ███████████████████████ 15%
Melbourne      1200 | ████████████████████    12%
Brisbane       1000 | █████████████████       10%
New York        900 | ███████████████          9%
Los Angeles     800 | ██████████████           8%
Toronto         750 | █████████████            7.5%
Vancouver       700 | ████████████             7%
San Francisco   650 | ███████████              6.5%
Chicago         600 | ██████████               6%
Montreal        550 | █████████                5.5%

------------
#### Cost Analysis




| **Component**             | **Configuration**                                              | **Cost Impact**                     | **Considerations**                                                                                   |
|---------------------------|-----------------------------------------------------------------|--------------------------------------|-----------------------------------------------------------------------------------------------------|
| **Apache Kafka**           | 1 Kafka Broker, 1 Zookeeper instance                           | **Medium**                           | Running in Docker. Kafka scales well for high-throughput but may incur additional costs in production environments for scaling, especially if hosted on the cloud. |
| **Apache Flink**           | 1 JobManager, 1 TaskManager (2-4 CPU cores, 8-16 GB RAM)       | **Medium**                           | Containerized within Docker. Suitable for smaller-scale tasks. Scalability and state management may incur higher costs as data volume grows. |
| **PostgreSQL Database**    | PostgreSQL in Docker                                            | **Low to Medium**                    | Minimal infrastructure cost as it runs locally within a container. However, as data size increases, performance tuning and scaling may become necessary, leading to higher costs. |
| **Docker & Docker Compose**| Docker for service orchestration (Kafka, Flink, PostgreSQL)     | **Low**                              | Docker is cost-efficient for local development and testing. For production, cloud container orchestration (e.g., AWS ECS, Kubernetes) may increase costs. |
| **CI/CD Pipeline (GitHub Actions)** | GitHub Actions for automated testing and deployment    | **Low**                              | GitHub Actions offers a free tier for small-scale jobs, though higher compute usage for large tests could result in additional costs. |
| **Persistent Storage**     | Docker volumes for Kafka logs, Flink checkpoints, PostgreSQL data | **Low**                              | Docker-managed storage is inexpensive for small-scale operations. Performance and storage limitations may arise as data volume grows. |
| **Networking**             | Internal Docker networking between containers (Kafka, Flink, PostgreSQL) | **Low**                              | Local Docker networking. For cloud-based setups, inter-service communication over the network can incur data transfer costs. |
| **Backup & Recovery**      | Manual backups for PostgreSQL & Kafka                          | **Low**                              | Backup processes are either manual or via simple scripts. A fully automated backup and disaster recovery solution would increase costs. |
| **Monitoring & Logging**   | Docker logs for monitoring and troubleshooting                  | **Low**                              | No centralized monitoring solution. Manual log management is sufficient for smaller setups but could become inefficient and costly as the system scales. |
| **Flink State & Checkpoints** | Stored in Docker container volumes                            | **Low**                              | Local storage for checkpoints and state. As the application scales, additional storage and management solutions would be required, leading to higher costs. |


#### **Cost Breakdown considerations**

The current **Docker-based setup** for the **Kafka-Flink-PostgreSQL pipeline** is **cost-effective** for small-scale development and testing. However, as you scale up the system (in terms of data volume and processing needs), you will need to assess potential **cloud migration** costs and invest in more robust **scaling**, **storage**, and **backup** solutions to ensure the pipeline can handle the growing demands of production.

- **Low-Cost Infrastructure**: The current setup uses **Docker containers** for local development, minimizing infrastructure costs. This approach is cost-effective for small-scale testing and development, leveraging free tiers for **CI/CD** via **GitHub Actions**.
  
- **Medium-Cost Components**: Key components like **Kafka** and **Flink** are running in Docker but will require scaling for larger data volumes and higher throughput, which can incur medium costs. If transitioned to cloud-based infrastructure, compute and storage costs could grow significantly based on the data size and required service uptime.
  
- **Scalability Concerns**: The current architecture, while sufficient for initial stages, may need optimization and scaling as the application moves towards production. Without proper scaling solutions (e.g., Kubernetes, cloud services), this could lead to higher operational overhead, particularly with respect to storage and compute needs for Kafka and Flink.
  
- **Potential Cloud Costs**: Should the system be migrated to cloud environments (e.g., AWS, GCP, or Azure), the costs will shift to pay-as-you-go models for compute (EC2 or equivalent), persistent storage (EBS, Cloud SQL), and network bandwidth (data transfer between services). Moreover, additional costs could arise from managed services (e.g., AWS MSK for Kafka, managed Flink on cloud) and scaling mechanisms (Kubernetes clusters).

- **Compute Resources**: If processing volumes increase, you may need more resources (e.g., additional Kafka brokers, Flink task managers). The current Docker-based setup is cost-efficient for development, but production environments require careful consideration of resource provisioning.
  
- **Storage Growth**: As the data grows, you may encounter limitations with local Docker volumes. Transitioning to cloud storage solutions (e.g., Amazon S3, Google Cloud Storage) or using distributed file systems for Flink state and PostgreSQL backup may increase costs but provide better scalability.
  
- **Backup & Disaster Recovery**: The current approach to backups is manual, which can be labor-intensive and prone to errors. A more automated, cloud-based backup solution (e.g., AWS RDS snapshots, Kafka topic backups) would add reliability but increase costs.
  
- **Operational Overhead**: Monitoring and logging in a local Docker setup are basic and could become inefficient for larger production environments. Cloud-based monitoring (e.g., Prometheus, Grafana, ELK Stack) or using managed services for Kafka and Flink would improve operational visibility but introduce additional costs.



