resource "aws_instance" "Java-Application" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.Java-Application-Key.key_name
  vpc_security_group_ids = ["${aws_security_group.Java-Application-SG.id}"]

  user_data = <<-EOF
                #!/bin/bash
                
            EOF

  tags = {
    Name = "Java-Application"
  }
}

