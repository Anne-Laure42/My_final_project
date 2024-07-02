terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "http" {} # for gitlab
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

