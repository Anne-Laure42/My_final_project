# --- DynamoDB Table  ---

# Use a dynamoDB table for state locking and consistency checking

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_lock
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"  
  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}