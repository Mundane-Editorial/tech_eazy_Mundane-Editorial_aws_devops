provider "aws" {
  region     = var.aws_region
  secret_key = var.secret_key_value
  access_key = var.access_key_value
}