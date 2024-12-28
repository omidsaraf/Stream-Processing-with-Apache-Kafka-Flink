
# Web Traffic Processing with Apache Kafka, PySpark, and PostgreSQL

**End-to-End Data Engineering Project**

This project demonstrates the implementation of an end-to-end **real-time data pipeline** using **Apache Kafka**, **PySpark**, and **PostgreSQL** to process and aggregate web traffic data. The solution consists of two main jobs:

1. **Start Job**: Processes raw web traffic data from Kafka, enriches it with geolocation information, and stores it in **PostgreSQL**.
2. **Aggregation Job**: Aggregates web traffic data based on specific dimensions (host and referrer), and stores the results for reporting and analysis.

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
9. [License](#license)

---

## **Overview**

The goal of this project is to simulate the end-to-end processing of web traffic data. **Apache Kafka** is used as the messaging system to consume real-time web traffic events, **PySpark** is employed to process and enrich the data, and **PostgreSQL** serves as the destination for storing processed and aggregated data.

---

## **Tools and Technologies**

This project leverages the following tools and technologies:

- **Apache Kafka**: A distributed streaming platform used to ingest real-time web traffic data.
- **PySpark**: A Python API for Apache Spark used for distributed data processing and transformations.
- **PostgreSQL**: A relational database for storing processed and aggregated web traffic data.
- **Docker**: Containerization tool for running Kafka and PostgreSQL services.
- **Python**: Programming language used for the data pipeline logic.

---

## **System Requirements**

Ensure the following system requirements are met:

- **Python 3.8+** (Recommended)
- **Apache Kafka** (Docker-based setup or cloud-hosted)
- **PostgreSQL** (Docker-based setup or cloud-hosted)
- **Docker** (To orchestrate Kafka and PostgreSQL services)
- **PySpark** (For distributed data processing)

---

## **Libraries Required**

To run the Python jobs, the following libraries are required. You can install them via `pip`:

```bash
pip install pyspark requests psycopg2 kafka-python pandas
```

---

## **Project Structure**

The project is structured as follows:

```plaintext
.
├── docker-compose.yml     # Docker Compose configuration for Kafka and PostgreSQL
├── job/
│   ├── start_job.py       # Python job to process web traffic data
│   └── aggregation_job.py # Python job to aggregate web traffic data
├── requirements.txt       # Python dependencies file
└── flink-env.env          # Environment variables for Kafka and PostgreSQL connections
```

---

## **Setup Guide**

Follow these steps to set up and run the project locally.

### **Step 1: Set Up Docker Services**

Start by setting up **Apache Kafka** and **PostgreSQL** services using Docker.

1. **Clone the repository**:

```bash
git clone https://github.com/yourusername/web-traffic-processing.git
cd web-traffic-processing
```

2. **Start the services**:

```bash
docker-compose up --build
```

This will start **Apache Kafka** and **PostgreSQL** in separate containers. Kafka will be used to consume web traffic data, and PostgreSQL will store the processed data.

---

### **Step 2: Configure Environment Variables**

Create a `.env` file and specify the environment variables for Kafka and PostgreSQL:

```env
KAFKA_URL=kafka:9092
POSTGRES_URL=jdbc:postgresql://postgres:5432/web_traffic_db
POSTGRES_USER=youruser
POSTGRES_PASSWORD=yourpassword
KAFKA_GROUP=web-traffic-consumer
KAFKA_TOPIC=web-traffic-topic
IP_CODING_KEY=your_ip_coding_api_key
```

---

## **Running the Jobs**

### **Start Job (Processing Web Traffic)**

The **start_job.py** script listens for web traffic events from **Kafka**, processes the events by enriching them with geolocation data, and writes the enriched data into **PostgreSQL**.

To run this job:

```bash
python job/start_job.py
```

### **Aggregation Job (Aggregating Web Traffic Data)**

The **aggregation_job.py** script reads processed web traffic data from **PostgreSQL**, aggregates it based on **host** and **referrer**, and stores the results back into **PostgreSQL** for analysis.

To run this job:

```bash
python job/aggregation_job.py
```

---

## **How It Works**

### **1. Web Traffic Data Processing**

1. **Data Ingestion (Kafka)**: Web traffic events, such as IP address, referrer, user agent, and URL, are ingested by **Kafka** in real time.
   
2. **Data Enrichment**: The **start_job.py** fetches additional geolocation information using an external API based on the IP address.

3. **PostgreSQL Storage**: The enriched data is written into a **PostgreSQL** database for further processing and querying.

### **2. Aggregation**

1. **Data Aggregation (PySpark)**: The **aggregation_job.py** script reads the processed data from **PostgreSQL**, performs aggregation operations like counting the number of hits per host and referrer, and writes the results back to **PostgreSQL**.



---

This **GitHub README** has been designed with a comprehensive approach to explain every step involved in the data pipeline. It ensures clarity on setting up, running, and understanding the full process.
