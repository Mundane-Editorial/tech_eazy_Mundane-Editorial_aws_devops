resource "aws_key_pair" "Java-Application-Key" {
  key_name   = "Java-Application-Key"
  public_key = file("${path.module}/key_pair/id_rsa.pub")
}
