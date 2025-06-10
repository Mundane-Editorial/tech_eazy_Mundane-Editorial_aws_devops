resource "aws_iam_instance_profile" "Java-Application-Profile" {
  name = "Java-Application-Profile"
  role = "${aws_iam_role.uploadonly_s3_role.name}"
}

resource "aws_iam_role_policy" "readonly_s3_policy" {
  name = "readonly_s3_policy"
  # description = "Policy to allow read-only access to S3 bucket"
  role = aws_iam_role.readonly_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "readonly_s3_role" {
  name = "readonly_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"  
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "readonly_s3_policy_attachment" {
  name       = "readonly_s3_policy_attachment"
  roles      = [aws_iam_role.readonly_s3_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy" "uploadonly_s3_policy" {
  name = "uploadonly_s3_policy"
  # description = "Policy to allow upload-only access to S3 bucket"
  role = aws_iam_role.uploadonly_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:createBucket",
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Deny"
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "uploadonly_s3_role" {
  name = "uploadonly_s3_role" 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "uploadonly_s3_policy_attachment" {
  name       = "uploadonly_s3_policy_attachment"
  roles      = [aws_iam_role.uploadonly_s3_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

