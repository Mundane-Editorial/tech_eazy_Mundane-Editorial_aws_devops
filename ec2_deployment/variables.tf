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
  type        = string
  default     = "19"
}

variable "repo_url" {
  description = "Github repository url"
  type        = string
}