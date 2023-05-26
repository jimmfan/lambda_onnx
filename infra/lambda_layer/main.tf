provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "layer_bucket" {
  bucket = "my-layer-bucket"
  acl    = "private"
}

resource "aws_lambda_layer_version" "xray_layer" {
  layer_name = "xray_layer"
  s3_bucket  = aws_s3_bucket.layer_bucket.id
  s3_key     = "xray_layer.zip"

  source_code_hash = filebase64sha256("xray_layer.zip")
  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_layer_permission" "xray_layer_permission" {
  layer_version_arn = aws_lambda_layer_version.xray_layer.arn
  statement_id      = "AllowLambdaToUseXrayLayer"
  action            = "lambda:GetLayerVersion"
  principal         = "lambda.amazonaws.com"
}

output "layer_arn" {
  value = aws_lambda_layer_version.xray_layer.arn
}
