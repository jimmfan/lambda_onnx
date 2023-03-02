/* Define the AWS Lambda function resource in your Terraform configuration file. */
resource "aws_lambda_function" "lambda_function" {
  filename      = "lambda_function_payload.zip"
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
}
/* Define the aws_vpc_endpoint resource in your Terraform configuration file and set the vpc_id and service_name attributes accordingly. You will also need to set the subnet_ids and security_group_ids attributes to the same values as your Lambda function. */
resource "aws_vpc_endpoint" "privatelink_endpoint" {
  vpc_id              = "vpc-12345678"
  service_name        = "com.amazonaws.vpce.us-east-1.vpce-svc-12345678901234567"
  subnet_ids          = aws_lambda_function.lambda_function.vpc_config[0].subnet_ids
  security_group_ids  = aws_lambda_function.lambda_function.vpc_config[0].security_group_ids
  private_dns_enabled = true
}
/* Define the aws_lambda_permission resource in your Terraform configuration file to allow the Lambda function to access the PrivateLink endpoint. You will need to set the source_arn attribute to the ARN of the IAM role that the Lambda function is using. */
resource "aws_lambda_permission" "privatelink_permission" {
  statement_id  = "AllowExecutionFromVPC"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "vpce.amazonaws.com"
  source_arn    = aws_iam_role.lambda_role.arn
}
/* Update the Lambda function resource to include the VPC configuration and set the subnet_ids and security_group_ids attributes to the same values as your PrivateLink endpoint. */
resource "aws_lambda_function" "lambda_function" {
  filename      = "lambda_function_payload.zip"
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  
  vpc_config {
    subnet_ids         = aws_vpc_endpoint.privatelink_endpoint.subnet_ids
    security_group_ids = aws_vpc_endpoint.privatelink_endpoint.security_group_ids
  }
}