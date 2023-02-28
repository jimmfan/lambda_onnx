import json
import boto3

from kafka import KafkaConsumer

import onnxruntime as rt

# Create an S3 client
s3 = boto3.client('s3')

# Define the S3 bucket and key for the model file
bucket = 'your-s3-bucket'
key = 'src/model_objects/logreg.onnx'

# Retrieve the model file from S3
model_response = s3.get_object(Bucket=bucket, Key=key)

# Load the model file using onnxruntime
session = rt.InferenceSession(model_response['Body'].read())

# Create a DynamoDB client
dynamodb = boto3.client('dynamodb')

# Define the Kafka consumer configuration
consumer_config = {
    'bootstrap_servers': 'your.kafka.broker.addresses:9092',
    'group_id': 'your-consumer-group-id',
    'security_protocol': 'SSL',
    'ssl_cafile': '/path/to/ca.pem',
    'ssl_certfile': '/path/to/service.cert',
    'ssl_keyfile': '/path/to/service.key'
}

kafka_topic = 'your-kafka-topic'
table_name = 'dynamodb_table'

# Create a Kafka consumer instance
consumer = KafkaConsumer(kafka_topic, **consumer_config)

# Start consuming messages from the Kafka topic
for message in consumer:
    # Parse the input data from the Kafka message
    data = json.loads(message.value.decode())

    # Make predictions using the loaded ML model
    predictions = session.run(data)

    # Define the DynamoDB table name
    table_name = 'your-dynamodb-table'

    # Write the predictions to DynamoDB
    item = {
        'id': {'S': data['id']},
        # 'timestamp': {'N': str(data['timestamp'])},
        'prediction': {'N': str(predictions[1][0])}
    }
    response = dynamodb.put_item(TableName=table_name, Item=item)

