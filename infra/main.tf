/* To provision an existing EKS Fargate cluster to invoke an AWS Lambda function image and put data into a DynamoDB table using Terraform, you can follow these general steps:

Define the AWS provider block in your Terraform configuration file, specifying your AWS access key, secret key, and region.
python
*/
provider "aws" {
  access_key = "<YOUR_ACCESS_KEY>"
  secret_key = "<YOUR_SECRET_KEY>"
  region     = "<YOUR_AWS_REGION>"
}
/* Define the required AWS resources to run your Lambda function as a container image using the aws_lambda_function resource block. */

resource "aws_lambda_function" "lambda_function" {
  function_name    = "<YOUR_LAMBDA_FUNCTION_NAME>"
  role             = "<YOUR_LAMBDA_ROLE_ARN>"
  handler          = "<YOUR_LAMBDA_HANDLER>"
  runtime          = "<YOUR_LAMBDA_RUNTIME>"
  image_uri        = "<YOUR_LAMBDA_IMAGE_URI>"
  package_type     = "Image"
  memory_size      = "<YOUR_LAMBDA_MEMORY_SIZE>"
  timeout          = "<YOUR_LAMBDA_TIMEOUT>"
  vpc_config       = "<YOUR_LAMBDA_VPC_CONFIG>"
  environment {
    variables = {
      TABLE_NAME = "<YOUR_DYNAMODB_TABLE_NAME>"
    }
  }
}
Define the Kubernetes Fargate service using the kubernetes_service resource block, and specify the AWS Lambda function as the container image.

resource "kubernetes_service" "lambda_service" {
  metadata {
    name = "<YOUR_K8S_SERVICE_NAME>"
  }

  spec {
    selector = {
      app = "<YOUR_APP_NAME>"
    }

    session_affinity = "ClientIP"

    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"

    pod_selector = {
      app = "<YOUR_APP_NAME>"
    }

    load_balancer_source_ranges = ["0.0.0.0/0"]
  }

  depends_on = [aws_eks_cluster.fargate_cluster]
  
  provider = {
    aws = {
      region = "<YOUR_AWS_REGION>"
    }
  }

  spec_template {
    container {
      image = aws_lambda_function.lambda_function.image_uri
      name  = "<YOUR_CONTAINER_NAME>"
      port {
        container_port = 8080
        name           = "http"
      }
      env {
        name  = "AWS_REGION"
        value = "<YOUR_AWS_REGION>"
      }
      env {
        name  = "AWS_ACCESS_KEY_ID"
        value = "<YOUR_AWS_ACCESS_KEY>"
      }
      env {
        name  = "AWS_SECRET_ACCESS_KEY"
        value = "<YOUR_AWS_SECRET_KEY>"
      }
    }
  }
}