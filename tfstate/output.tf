output "s3_bucket_arn" {
  value       = aws_s3_bucket.tfstate_bucket.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "The name of the DynamoDB table"
}