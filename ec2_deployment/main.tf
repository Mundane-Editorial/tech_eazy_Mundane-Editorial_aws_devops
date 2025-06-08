resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = <<-EOF
                #!/bin/bash
                
            EOF

  tags = {
    Name = "Java-Application"
  }
}