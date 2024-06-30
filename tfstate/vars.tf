variable "project" {
  description = "project description tags"
  default     = "my_project"
}

variable "aws_region" {
  description = "The AWS region of the cluster deployment"
  default     = "eu-west-3"
}

variable "tfstate_bucket" {
  description = "S3 bucket name"
  default     = "myproject-state-backend"
}

variable "dynamodb_lock" {
  description = "DynamoDB Table for tfstate"
  default     = "terraform_state_lock"
}