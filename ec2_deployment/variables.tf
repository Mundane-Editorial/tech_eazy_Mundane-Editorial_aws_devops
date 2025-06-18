variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1" # Mumbai
}

variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-09299e47e83cceaa7" # amazon linux 2 - free tier eligible
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "shutdown_threshold" {
  description = "Machine Shutdown Threshold"
  type        = number
  default     = 20
}

variable "java_version" {
  description = "Java version"
  type        = number
  default     = 19
}

variable "repo_url" {
  description = "Github repository url"
  type        = string
  default     = "https://github.com/techeazy-consulting/techeazy-devops"
}

variable "access_key_value" {
  description = "AWS access key"
  type        = string
}

variable "secret_key_value" {
  description = "AWS secret key"
  type        = string
}

variable "instance_user" {
  type    = string
  default = "ec2-user"
}

variable "bucket_name" {
  description = "S3 bucket name for storing artifacts"
  type        = string

  validation {
    condition     = length(var.bucket_name) > 0
    error_message = "bucket_name must not be empty."
  }
}

variable "stage" {
  description = "Deployment stage"
  type        = string
}

# variable "ec2_private_key" {
#   description = "Private key for EC2 SSH provisioning"
#   type        = string
#   sensitive   = true
# }

# variable "ec2_public_key" {
#   description = "Public key for EC2 SSH provisioning"
#   type        = string
#   sensitive   = true
# }

variable "ec2_key_name" {
  description = "Name of existing EC2 key pair"
  type        = string
  default     = "Java-Application-Key"
}