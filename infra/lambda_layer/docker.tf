resource "docker_image" "my_image" {
  name         = "ubuntu:20.04"
  keep_locally = false
}

resource "docker_container" "my_container" {
  name  = "my_container"
  image = docker_image.my_image.latest

  command = [
    "bash",
    "-c",
    "apt-get update && apt-get install -y zip python3-pip && mkdir /lambda_layers && pip3 install aws-xray-sdk && cd /lambda_layers && zip -r xray_package.zip *"
  ]

  depends_on = [docker_image.my_image]
}

resource "aws_lambda_layer_version" "xray_layer" {
  filename   = "xray_package.zip"
  layer_name = "xray_layer"
  compatible_runtimes = ["python3.8"]
}
