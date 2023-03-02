provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "lambda" {
  metadata {
    name = "lambda"
  }

  spec {
    selector {
      match_labels = {
        app = "lambda"
      }
    }

    template {
      metadata {
        labels = {
          app = "lambda"
        }
      }

      spec {
        container {
          image = "012345678910.dkr.ecr.us-east-1.amazonaws.com/lambda:latest"
          name  = "lambda"

          env {
            name  = "TABLE_NAME"
            value = "my-dynamo-table"
          }

          env {
            name  = "KAFKA_BOOTSTRAP_SERVERS"
            value = "my-kafka-bootstrap-server:9092"
          }

          env {
            name  = "KAFKA_TOPIC"
            value = "my-kafka-topic"
          }
        }

        # Fargate specific configuration
        node_selector = {
          "eks.amazonaws.com/fargate" = "true"
        }

        tolerations {
          key    = "dedicated"
          value  = "fargate"
          effect = "NoSchedule"
        }

        # Set the service account to use
        service_account_name = "lambda"
      }
    }
  }
}

resource "aws_lambda_event_source_mapping" "kafka_mapping" {
  event_source_arn = "arn:aws:kafka:${var.region}:${var.account_id}:cluster/${var.kafka_cluster_id}/topic/${var.kafka_topic}"
  function_name    = "${aws_lambda_function.lambda_function.arn}"
  batch_size       = 10
}