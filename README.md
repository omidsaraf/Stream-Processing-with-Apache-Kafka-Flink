
# Web Traffic Stream Processing with Apache Kafka, Flink, and Postgres

### End-to-End Data Engineering Pipeline for Web Traffic Logs

This project implements an **end-to-end real-time data pipeline** that processes web traffic logs using **Apache Kafka**, **Apache Flink**, and stores the results in a **Postgres** database. The pipeline streams web traffic data, applies real-time transformations and aggregations, and stores the output in Postgres for further analytics.

---

## Table of Contents

- [Overview](#overview)
- [Technologies Used](#technologies-used)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project demonstrates a scalable, real-time data pipeline for web traffic processing. It integrates **Apache Kafka** for message streaming, **Apache Flink** for real-time data processing, and **Postgres** for storing processed data. The pipeline follows these key steps:

1. **Kafka** ingests web traffic data (URL, referrer, user-agent, etc.).
2. **Flink** processes the data, performing operations like IP geolocation lookup and event aggregation.
3. The processed data is stored in **Postgres** for querying and analysis.

---

## Technologies Used

- **Apache Kafka**: Distributed event streaming platform used to ingest real-time web traffic data.
- **Apache Flink**: Real-time stream processing framework that aggregates and processes web traffic data.
- **Postgres**: Relational database to store processed and aggregated web traffic data.
- **Docker**: Containerization platform to run all services.
- **Python**: Used to orchestrate jobs and transformations within Flink.
- **UDFs (User-Defined Functions)**: Custom functions for geolocation lookups (IP to country, city, etc.) integrated with Flink.

---

## Project Structure

```plaintext
├── docker-compose.yml          # Docker Compose file to manage Kafka, Flink, and Postgres services
├── Dockerfile                  # Dockerfile to build the Flink image
├── requirements.txt            # Python dependencies (Flink, Kafka, etc.)
├── flink-env.env               # Environment variables for Flink
├── src/
│   ├── job/
│   │   ├── start_job.py        # Python job for processing web traffic
│   │   └── aggregation_job.py  # Python job for aggregating web traffic data
└── README.md                   # Project documentation
```

---

## Setup

### 1. Clone the Repository

Start by cloning this repository:

```bash
git clone https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink.git
cd Stream-Processing-with-Apache-Kafka-Flink
```

### 2. Configure Environment Variables

Create a `.env` file in the root of the project and set the following environment variables:

```env
KAFKA_URL=your-kafka-broker-url
KAFKA_TOPIC=your-kafka-topic
KAFKA_GROUP=your-consumer-group
POSTGRES_URL=jdbc:postgresql://your-postgres-url
POSTGRES_USER=your-postgres-username
POSTGRES_PASSWORD=your-postgres-password
POSTGRES_DB=your-postgres-database
IP_CODING_KEY=your-ip-coding-api-key
```

These variables are required for the Kafka and Postgres configurations to connect properly.

### 3. Build the Docker Containers

To build the necessary services (Kafka, Flink, Postgres) with Docker Compose, run:

```bash
docker-compose build
```

---

## Usage

### 1. Start the Services

To start the Docker containers, use:

```bash
docker-compose up -d
```

This command will start Kafka, Flink, and Postgres in the background.

### 2. Submit the Web Traffic Processing Job

To begin processing the web traffic logs, run the following command:

```bash
make job
```

This will launch a Flink job that listens to the Kafka topic, processes incoming events, and stores the results in the Postgres database.

### 3. Run the Aggregation Job

For aggregating the processed data (grouped by host and referrer), run:

```bash
make aggregation_job
```

This job will aggregate the processed web traffic logs and store the aggregated results in Postgres.

---

## Contributing

We welcome contributions to improve the functionality or add features to this project. To contribute:

1. Fork this repository
2. Clone your forked repository:
   ```bash
   git clone https://github.com/<your-username>/Stream-Processing-with-Apache-Kafka-Flink.git
   ```
3. Create a new branch:
   ```bash
   git checkout -b feature-branch
   ```
4. Make your changes and commit them:
   ```bash
   git commit -m "Describe your changes"
   ```
5. Push your changes:
   ```bash
   git push origin feature-branch
   ```
6. Open a pull request for review.

---
