output "ec2_instance_ip" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.Java-Application.public_ip
}

output "ami_id" {
  description = "The AMI ID used for the EC2 instance"
  value       = var.ami_id
}

output "open_ports" {
  description = "Open ports in the security group"
  value       = aws_security_group.Java-Application-SG.ingress[*].from_port
}