# resource "null_resource" "generate_ssh_key" {
#   provisioner "local-exec" {
#     command = <<EOT
#       mkdir -p ${path.module}/key_pair
#       if [ ! -f "${path.module}/key_pair/id_rsa" ]; then
#         ssh-keygen -t rsa -b 2048 -f ${path.module}/key_pair/id_rsa -q -N ""
#       fi
#     EOT
#   }

#   triggers = {
#     always_run = "${timestamp()}"
#   }
# }

# resource "aws_key_pair" "generated_key" {
#   depends_on = [null_resource.generate_ssh_key]
#   key_name   = var.ec2_key_name
#   public_key = file("${path.module}/key_pair/id_rsa.pub")
# }

resource "aws_instance" "Java-Application" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.Java-Application-Key.key_name
  vpc_security_group_ids = [aws_security_group.Java-Application-SG.id]
  iam_instance_profile   = aws_iam_instance_profile.Java-Application-Profile.name

  provisioner "file" {
    source      = "${path.module}/scripts/setup.sh"
    destination = "/home/${var.instance_user}/setup.sh"

    connection {
      type        = "ssh"
      user        = var.instance_user
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.instance_user}/setup.sh",
      "/home/${var.instance_user}/setup.sh ${var.java_version} ${var.repo_url} ${var.shutdown_threshold} ${aws_s3_bucket.artifact_bucket.bucket}"
    ]

    connection {
      type        = "ssh"
      user        = var.instance_user
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }

  tags = {
    Name        = "Java-Application-${var.stage}"
    Environment = var.stage
  }
}
