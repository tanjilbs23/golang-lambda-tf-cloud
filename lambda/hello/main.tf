resource "null_resource" "lambda_build" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }
  # triggers = {
  #   on_every_apply = uuid()
  # }
  triggers = {
    file_hashes = jsonencode({
      for fn in fileset("${path.module}/src", "**") :
      fn => filesha256("${path.module}/src/${fn}")
    })
  }
  provisioner "local-exec" {
    command = "cd ${path.module};wget https://go.dev/dl/go1.19.2.linux-amd64.tar.gz;tar -xzf go1.19.2.linux-amd64.tar.gz -C .;cd go/bin;export PATH=$PATH:$(pwd);go version;cd ../../src;go build -o ../bin/handler;cd ..;ls -la;pwd;"

  }
}

data "archive_file" "lambda_go_zip" {

  type        = "zip"
  source_file = "${path.module}/bin/handler"
  output_path = "${path.module}/bin/handler.zip"

  depends_on = [
    null_resource.lambda_build
  ]
}


module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "handler"
  description   = "testing go function"go build -o ../bin/handler
  handler       = "handler.lambda_handler"
  runtime       = "go1.x"

  create_package         = false
  local_existing_package = "${path.module}/bin/handler.zip"

  trusted_entities = [
    {
      type = "Service",
      identifiers = [
        "appsync.amazonaws.com"
      ]
    }
  ]

  tags = {
    Name = var.tags
  }

  depends_on = [
    data.archive_file.lambda_go_zip
  ]
}