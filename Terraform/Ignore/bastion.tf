resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = module.infra.public_subnets_id[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = aws_key_pair.project_key.key_name
  provisioner "file" {
    source      = var.key_file
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
  connection {
    host        = self.public_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = file("${var.key_file}")
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/.ssh/id_rsa"
    ]
  }
  tags = {
    Name = "Bastion"
  }
}

resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = module.infra.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "bastion_server" {
  value = aws_instance.bastion.public_ip
}