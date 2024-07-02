variable "project" {
  description = "project description tags"
  default     = "my_project"
}

variable "aws_region" {
  description = "The AWS region of the cluster deployment"
  default     = "eu-west-3"
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = true
}

variable "public_subnets_cidrs" {
  description = "Public Subnets CIDR values"
  type        = list(string)
  default     = ["10.99.0.0/24", "10.99.1.0/24"]
}

variable "private_subnets_cidrs" {
  description = "Private Subnets CIDR values"
  type        = list(string)
  default     = ["10.99.2.0/24", "10.99.3.0/24"]
}

variable "db_subnets_cidrs" {
  description = "Database isolated Subnets CIDR values"
  type        = list(string)
  default     = ["10.99.4.0/24", "10.99.5.0/24"]
}

variable "cluster_name" {
  description = "Cluster name"
  default     = "my-ecs-cluster"
}

variable "instance_type" {
  description = "EC2 Instance type for the ecs cluster"
  type        = string
  default     = "t2.micro"
}

variable "image_id" {
  description = "Amazon Linux Optimazed image id"
  type        = string
  default     = "ami-02871451a3c09683b"
}

variable "ecs_container_name" {
  description = "Container's app name"
  default     = "my-python-app"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "multi_az_db" {
  type    = bool
  default = true
}

variable "my_s3_bucket" {
  description = "S3 bucket name"
  default     = "pythonapp-ecs-logs-bucket"
}

variable "alert_email" {
  description = "Email to receive CloudWatch alarm notifications"
  type        = string
  default     = "annelaure423302101@gmail.com"
}


variable "db_name" {
  description = "DB name"
  default     = "my-db-sql"
}


variable "db_username" {
  description = "DB username"
  sensitive   = true
}

variable "db_password" {
  description = "DB password"
  sensitive   = true
}