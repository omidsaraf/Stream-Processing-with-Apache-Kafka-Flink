FROM flink:1.16.2

# Install Python and necessary dependencies for PyFlink
RUN apt-get update -y && \
    apt-get install -y python3 python3-pip && \
    pip3 install apache-flink kafka-python psycopg2

# Install Java 11 for Flink
RUN apt-get install -y openjdk-11-jdk && \
    apt-get clean

# Set environment variables for Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy the job files into the container
COPY . /opt/flink/
WORKDIR /opt/flink

# Set the default entrypoint to run the job
CMD ["python3", "web_traffic_pyspark.py"]
