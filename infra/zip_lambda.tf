resource "null_resource" "deploy_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      # Create a temporary directory to store the deployment package
      mkdir lambda_package
      # Copy the Lambda function code to the temporary directory
      cp lambda_function.py lambda_package/
      # Create a directory for dependencies
      mkdir lambda_package/python
      # Copy your Python dependencies to the dependencies directory
      cp -R my_dependency1 lambda_package/python/
      cp -R my_dependency2 lambda_package/python/
      # Create the deployment package as a ZIP file
      cd lambda_package
      zip -r ../my_lambda_function.zip .
      # Clean up the temporary directory
      cd ..
      rm -rf lambda_package
      # Deploy the Lambda function using the AWS CLI
      aws lambda create-function --function-name my-lambda-function --runtime python3.8 --role ${aws_iam_role.my_lambda_role.arn} --handler lambda_function.lambda_handler --zip-file fileb://my_lambda_function.zip
    EOT
  }
}
