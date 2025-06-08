resource "aws_instance" "Java-Application" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.Java-Application-Key.key_name
  user_data = <<-EOF
                #!/bin/bash
                
            EOF

  tags = {
    Name = "Java-Application"
  }
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value = aws_instance.Java-Application.public_ip
}