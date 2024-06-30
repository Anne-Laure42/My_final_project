terraform {
  backend "s3" {
    bucket         = var.my_s3_bucket
    key            = "s3/tf-state/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = var.dynamodb_lock
    encrypt        = true
  }
}