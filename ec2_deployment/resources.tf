resource "aws_key_pair" "Java-Application-Key" {
  key_name   = "Java-Application-Key"
  public_key = file("${path.module}/key_pair/id_rsa.pub")
}

resource "aws_security_group" "Java-Application-SG" {
  name        = "Java-Application-SG"
  description = "Security group for Java Application"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Java-Application-SG"
  }
}