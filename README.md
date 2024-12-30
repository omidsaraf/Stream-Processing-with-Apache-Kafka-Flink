
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
5. [Setup Guide](#setup-guide)
6. [Check Environments](#check-environments)
7. [Running the Jobs](#running-the-jobs)
8. [Job Processing](#job-processing)
   1. [How It Works](#how-it-works)
   2. [Testing the Processing Job](#testing-the-processing-job)
10. [CI/CD Setup](#cicd-setup)
16. [Exploratory Analysis](#exploratory-analysis)
17. [Cost Analysis](#cost-analysis)

---

### **Project Structure**

![image](https://github.com/user-attachments/assets/24f450f8-7132-4093-820b-b7e863ff69d7)


------------

### **Workflow and Layers**


| **Layer**                | **Storage**    | **Pipeline**                         | **Process**                                                                                  | **Cluster**                | **Cluster Manager**                                  |
|--------------------------|----------------|--------------------------------------|----------------------------------------------------------------------------------------------|----------------------------|------------------------------------------------------|
| **Data Ingestion**        | Kafka Topics   | Web Servers, Kafka Producers         | Collect data from web servers, send to Kafka Topics                                          | Kafka Cluster              | Zookeeper                                             |
| **Data Processing**       | Memory         | Kafka Topics, Spark Streaming        | Read data from Kafka Topics, process data with Spark Streaming, orchestrate with Flink         | Spark Cluster, Flink Cluster| Flink Job Manager, Flink Task Manager, Spark Driver  |
| **Data Aggregation**      | Memory         | Flink, Data Windows                  | Aggregate data by host and referrer using DataFrame operations                                | Spark Cluster, Flink Cluster| Flink Job Manager, Flink Task Manager, Spark Driver  |
| **Data Storage**          | PostgreSQL     | Flink Output, Data Tables            | Store aggregated data in PostgreSQL tables, make data queryable                               | PostgreSQL Nodes           | N/A (PostgreSQL manages its own data)                |
| **CI/CD & Development**   | GitHub Repos   | Build, Test, Deploy                  | Automate build, test, and deploy using GitHub Actions, use Docker for consistent environments, development in VS Code | Development and CI/CD environments | N/A (Managed by GitHub Actions and Docker orchestration) |

------------

---

### **Tools and Technologies**

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

### **Required Libraries**

To run the Python jobs, the following libraries are required. You can install them via `pip`:

```bash
pip install pyspark requests psycopg2 kafka-python pandas
pip install -r libraries.txt
```
------

### **Setup Guide**

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

### **Check Environments**

##### **Docker**

![Docker](https://github.com/user-attachments/assets/b5e1ff83-dc1c-4629-ba75-da2437dd2891)

##### **Postgres**

Login to **pgAdmin** and create the sink (target table).

![image](https://github.com/user-attachments/assets/18568f7c-94df-4d24-ae00-5ac2ee76536c)


##### **Apache Flink**

Access **Apache Flink** via the UI at [http://localhost:8081/#/overview](http://localhost:8081/#/overview).

![image](https://github.com/user-attachments/assets/f01d0301-f25f-4c0d-bfb9-27b9d94fa980)


---

### **Job Processing**
[Job code](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/Job/Processing%20job.py)
[Explain the code](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/Job/code%20explain.md)
#### **How It Works**

To run this job:

```bash
python job/Processing_job.py
```

This job:
- Connects to a **Kafka topic** to stream real-time web traffic data.
- Processes the data by parsing the JSON and performing aggregation based on **host** and **referrer** within **5-minute windows**.
- Writes the aggregated web traffic statistics (the number of hits) into a **PostgreSQL database** in an **append-only** manner.

--------
#### **Testing the Processing Job**

[PyTest.py](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/Job/test_processing_job.py)

- Defines a test function test_data_processing that tests the data processing logic.
- Creates sample input data to mimic actual data.
- Defines the schema for the input data.
- Creates a DataFrame from the input data using the Spark session.
- Calls the process_data function with the input DataFrame.
- Performs assertions on the processed DataFrame:
- Checks that the number of rows in the processed DataFrame matches the input data.
- Checks if the num_hits column exists in the processed DataFrame.

------
### **CI/CD Setup**

[CI/CD code](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/.github/workflows/ci.yml)

This GitHub Actions workflow automates your CI/CD process. Here's a concise breakdown:

##### Triggers
- **Push** to `main` branch
- **Pull requests** targeting `main` branch

##### Jobs
1. **Build**:
   - Runs on `ubuntu-latest`
   - Sets up PostgreSQL and Kafka services with health checks

2. **Install Dependencies**:
   - Runs on `ubuntu-latest`
   - Steps:
     - Checkout code
     - Set up Python 3.7
     - Install dependencies from `libraries.txt` and `pytest`

3. **Test**:
   - Runs on `ubuntu-latest`
   - Depends on `install_dependencies`
   - Steps:
     - Checkout code
     - Run tests with `pytest`

4. **Docker**:
   - Runs on `ubuntu-latest`
   - Depends on `test`
   - Steps:
     - Checkout code
     - Build Docker image
     - Run Docker containers with `docker-compose`
     - Stop and clean up Docker containers and images

------
#### Exploratory Analysis
[Code Space](https://github.com/omidsaraf/Stream-Processing-with-Apache-Kafka-Flink/blob/main/exploratory%20analysis/countribution%20analysis.sql)

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
| {"city": "Tehran", "count": 550}            | {"country": "Iran", "total_count": 1500}               | 5.50%                   | 500                       | 600                   | 100               |


###### City Contributions


| City              | Contributions | Percentage Contribution | Bar                                       |
|-------------------|---------------|-------------------------|-------------------------------------------|
| Sydney            | 1500          | 15%                     | ████████████████████████████████████████  |
| Melbourne         | 1200          | 12%                     | █████████████████████████████████        |
| Brisbane          | 1000          | 10%                     | ███████████████████████████              |
| New York          | 900           | 9%                      | ███████████████████████                  |
| Los Angeles       | 800           | 8%                      | █████████████████████                    |
| Toronto           | 750           | 7.5%                    | ████████████████████                     |
| Vancouver         | 700           | 7%                      | ███████████████████                      |
| San Francisco     | 650           | 6.5%                    | ██████████████████                       |
| Chicago           | 600           | 6%                      | █████████████████                        |
| Tehran            | 550           | 5.5%                    | ████████████████                         |


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



