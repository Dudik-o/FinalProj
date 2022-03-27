resource "aws_instance" "database" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = module.infra.private_subnets_id[0]
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  key_name               = aws_key_pair.project_key.key_name
  tags = {
    Name = "Database"
  }
}


resource "aws_security_group" "db-sg" {
  name   = "db-security-group"
  vpc_id = module.infra.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "db_server" {
  value = aws_instance.database.private_ip
}