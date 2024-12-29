import pytest
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from Processing_job import process_data  # Import the modularized function

@pytest.fixture(scope="session")
def spark():
    """Fixture to set up a Spark session for testing."""
    spark = SparkSession.builder.master("local[1]").appName("PySpark Testing").getOrCreate()
    yield spark
    spark.stop()

def test_data_processing(spark):
    """Test the data processing logic."""
    # Sample input data (replace with actual test cases or mock data)
    input_data = [
        ("example.com", "google.com", "Mozilla", "example.com", "192.168.1.1", "header_data", "2024-12-29T12:00:00Z"),
        ("example.org", "bing.com", "Chrome", "example.org", "192.168.1.2", "header_data", "2024-12-29T12:05:00Z"),
    ]
    
    schema = ["url", "referrer", "user_agent", "host", "ip", "headers", "event_time"]
    
    # Create DataFrame from input data
    input_df = spark.createDataFrame(input_data, schema)
    
    # Call the `process_data` function
    processed_df = process_data(input_df)

    # Perform assertions on the processed data
    assert processed_df.count() == 2  # Example assertion: Number of rows should match the input data
    assert "num_hits" in processed_df.columns  # Check if aggregation column exists
    assert processed_df.filter(col("num_hits") > 0).count() > 0  # Ensure aggregation happens properly
