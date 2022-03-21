
resource "aws_instance" "ansible-server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = module.infra.private_subnets_id[0]
  vpc_security_group_ids = [aws_security_group.ansible-sg.id]
  key_name               = aws_key_pair.project_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.dynamic-inventory_profile.name
  provisioner "file" {
    source      = var.key_file
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
  provisioner "file" {
    source      = "../ansible-roles"
    destination = "/home/ubuntu/"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible -y",
      "sudo apt install ansible -y",
      "sudo apt install python-pip -y",
      "sudo -H pip install boto3",
      "sudo -H pip install botocore",
      "sudo mkdir -p /opt/ansible/inventory",
      "sudo cp /home/ubuntu/ansible-roles/aws_ec2.yaml /opt/ansible/inventory",
      "sudo chmod 400 /home/ubuntu/.ssh/id_rsa",
      "sudo sed -i '327 a enable_plugins = aws_ec2' /etc/ansible/ansible.cfg",
      "sudo sed -i '13 a inventory      =  /opt/ansible/inventory/aws_ec2.yaml' /etc/ansible/ansible.cfg",
      "sudo sed -i '71 a host_key_checking = False' /etc/ansible/ansible.cfg",
      "ansible-playbook /home/ubuntu/ansible-roles/configuration.yaml"
    ]
  }
  connection {
    host        = self.private_ip
    private_key = file("${var.key_file}")
    user        = "ubuntu"
    bastion_host     = aws_instance.bastion.public_ip
    bastion_host_key = file("${var.key_file}")
  }
  tags = {
    Name = "Ansible"
  }
}


resource "aws_security_group" "ansible-sg" {
  name        = "ansible-sg"
  description = "security group for ansible server"
  vpc_id      = module.infra.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "dynamic-inventory" {
  name               = "dynamic-inventory"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

resource "aws_iam_policy" "dynamic-inventory_policy" {
  name        = "dynamic-inventory"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/dynamic-inventory.json")
}

resource "aws_iam_policy_attachment" "dynamic-inventory_policy_attachment" {
  name       = "dynamic-inventory"
  roles      = [aws_iam_role.dynamic-inventory.name]
  policy_arn = aws_iam_policy.dynamic-inventory_policy.arn
}


resource "aws_iam_instance_profile" "dynamic-inventory_profile" {
  name = "ansible-dynamic-inventory"
  role = aws_iam_role.dynamic-inventory.name
}


output "ansible_server" {
  value = aws_instance.ansible-server.private_ip
}