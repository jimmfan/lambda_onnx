/* Install the terraform-provider-kafkaconnect plugin: You can install the terraform-provider-kafkaconnect plugin to interact with the Kafka Connect REST API. You can download the plugin from the official Terraform registry.

Create an IAM role for the Lambda function: You need to create an IAM role that the Lambda function can assume to access other AWS services. For example, if you want to access a Kafka cluster hosted on AWS MSK, you need to give the IAM role access to the AmazonMSKFullAccess policy.

Create a Lambda function: You can create a Lambda function using Terraform's aws_lambda_function resource. The function should have the necessary permissions to assume the IAM role you created in step 2.

Create a Kafka connector configuration: You can use Terraform's kafkaconnect_connector_config resource to define a Kafka connector configuration. This resource defines the configuration settings for the connector, including the name, Kafka topic, and Kafka cluster details.

Create a Kafka connector: Finally, you can use the kafkaconnect_connector resource to create a new Kafka connector using the configuration you defined in step 4. This resource also specifies the AWS Lambda function as the destination for the Kafka data. */



provider "kafkaconnect" {
  endpoint = "http://kafka-connect-host:8083"
}

resource "aws_iam_role" "lambda" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "connector" {
  function_name = "my-kafka-connector"
  handler = "index.handler"
  runtime = "nodejs14.x"
  role = aws_iam_role.lambda.arn

  # Add any additional environment variables or configuration here
  environment {
    variables = {
      KAFKA_BOOTSTRAP_SERVERS = "kafka-bootstrap-servers:9092"
      KAFKA_TOPIC = "my-kafka-topic"
    }
  }
}

resource "kafkaconnect_connector_config" "my-connector-config" {
  name = "my-kafka-connector-config"
  connector_class = "io.confluent.connect.aws.lambda.AwsLambdaSinkConnector"
  config = {
    "topics" = "${var.kafka_topic}"
    "aws.region" = "us-west-2"
    "aws.lambda.function.name" = "${aws_lambda_function.connector.function_name}"
    "aws.lambda.invocation.type" = "sync"
  }
}

resource "kafkaconnect_connector" "my-connector" {
  name = "my-kafka-connector"
  connector_class = "io.confluent.connect.aws.lambda.AwsLambdaSinkConnector"
  config {
    config = kafkaconnect_connector_config.my-connector-config.id
  }
}
