# Create an S3 bucket for logs
resource "aws_s3_bucket" "ecs_logs_bucket" {
  bucket = var.my_s3_bucket
}