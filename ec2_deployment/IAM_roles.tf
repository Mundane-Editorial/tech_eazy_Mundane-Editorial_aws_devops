# Instance profile that connects EC2 to the IAM role
resource "aws_iam_instance_profile" "Java-Application-Profile" {
  name = "Java-Application-Profile"
  role = aws_iam_role.uploadonly_s3_role.name

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}

# EC2 role to allow upload-only access to S3
resource "aws_iam_role" "uploadonly_s3_role" {
  name = "uploadonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Upload-only S3 custom policy
resource "aws_iam_policy" "uploadonly_s3_policy" {
  name = "uploadonly_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.artifact_bucket.bucket}/*"
        ]
      }
    ]
  })
}

# Attach the upload-only policy to the upload role
resource "aws_iam_role_policy_attachment" "uploadonly_s3_policy_attachment" {
  role       = aws_iam_role.uploadonly_s3_role.name
  policy_arn = aws_iam_policy.uploadonly_s3_policy.arn
}

# Optional: Read-only role if needed separately (unchanged)
resource "aws_iam_role" "readonly_s3_role" {
  name = "readonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS-managed read-only policy to that role
resource "aws_iam_policy_attachment" "readonly_s3_policy_attachment" {
  name       = "readonly_s3_policy_attachment"
  roles      = [aws_iam_role.readonly_s3_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
