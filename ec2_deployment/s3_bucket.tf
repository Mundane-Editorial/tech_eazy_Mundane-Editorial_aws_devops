resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${var.bucket_name}-${random_id.suffix.hex}"

  force_destroy = true  # for development purpose only

  tags = {
    Name        = var.bucket_name
    Environment = "Development"
  }
}

# resource "aws_s3_bucket_acl" "artifact_bucket_acl" {
#   bucket = aws_s3_bucket.artifact_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "artifact_bucket_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "artifact_bucket_public_access_block" {
  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact_bucket_lifecycle" {
  bucket = aws_s3_bucket.artifact_bucket.id

  rule {
    id     = "delete_app_logs"
    status = "Enabled"

    filter {
      prefix = "app/logs/"
    }

    expiration {
      days = 7
    }
  }

  rule {
    id     = "delete_ec2_logs"
    status = "Enabled"

    filter {
      prefix = "ec2-logs/"
    }

    expiration {
      days = 7
    }
  }
}