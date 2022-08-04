terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  default_tags {
    tags = {
      env         = "development"
      product     = "imperva-dsf-hub"
      managed-by  = "terraform"
    }
  }
}