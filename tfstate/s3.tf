# --- S3 Bucket  ---

# Configure an S3 bucket resource to hold application state files
resource "aws_s3_bucket" "tfstate_bucket" {
    bucket = var.tfstate_bucket

    lifecycle {
    prevent_destroy = true
  }
}


# Add bucket versioning for state rollbackcheck
resource "aws_s3_bucket_versioning" "tfstate_version" {
    bucket = aws_s3_bucket.tfstate_bucket.id

    versioning_configuration {
      status = "Enabled"
    }
}

# Add bucket encryption to hide sensitive state data
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.tfstate_bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}