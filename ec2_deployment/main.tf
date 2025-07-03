resource "aws_instance" "Java-Application" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.Java-Application-Key.key_name
  vpc_security_group_ids = ["${aws_security_group.Java-Application-SG.id}"]
  iam_instance_profile   = aws_iam_instance_profile.Java-Application-Profile.name

  provisioner "file" {
    source      = "${path.module}/scripts/setup.sh"
    destination = "/home/${var.instance_user}/setup.sh"

    connection {
      type        = "ssh"
      user        = var.instance_user
      private_key = file("${path.module}/key_pair/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y unzip git curl",
      "chmod +x /home/${var.instance_user}/setup.sh",
      "/home/${var.instance_user}/setup.sh ${var.java_version} ${var.repo_url} ${var.shutdown_threshold} ${aws_s3_bucket.artifact_bucket.bucket} ${var.stage}"
    ]

    connection {
      type        = "ssh"
      user        = var.instance_user
      private_key = file("${path.module}/key_pair/id_rsa")
      host        = self.public_ip
    }
  }

  tags = {
    Name  = "Java-Application"
    Stage = var.stage
  }
}

//test