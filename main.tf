terraform {
  cloud {
    organization = "personal-testing-terraform"

    workspaces {
      name = "golang-lambda-tf-cloud"
    }
  }
}

provider "aws" {}

# variable "tags" {}

# module "hello" {
#   source = "./lambda/hello"
#   tags   = var.tags
# }