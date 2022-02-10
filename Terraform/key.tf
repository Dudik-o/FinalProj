resource "tls_private_key" "project_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "project_key" {
  key_name   = var.key_name
  public_key = tls_private_key.project_key.public_key_openssh
}

resource "local_file" "project_key" {
  sensitive_content = tls_private_key.project_key.private_key_pem
  filename          = var.key_file
}





