resource "aws_lambda_function" "lambda" {
  function_name = "lambda-function"
  role          = aws_iam_role.lambda.arn
  handler       = "index.handler"
  runtime       = "provided.al2"

  image_uri     = "012345678910.dkr.ecr.us-west-2.amazonaws.com/my-lambda-image:latest"

  environment {
    variables = {
      DYNAMODB_TABLE = "example-table"
    }
  }

  depends_on = [
    aws_ecr_repository.lambda,
    aws_iam_role.lambda,
    aws_iam_role_policy.lambda,
  ]
}

resource "aws_ecr_repository" "lambda" {
  name = "my-lambda-repo"
}

resource "aws_iam_role" "lambda" {
  name = "lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.example.arn
      }
    ]
  })
}

resource "aws_dynamodb_table" "example" {
  name           = "example-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}