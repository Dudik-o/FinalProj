resource "aws_instance" "jenkins_server" {
  ami           = "ami-01723c653ff8c83fb"
  instance_type = var.instance_type
  key_name      = aws_key_pair.project_key.key_name
  security_groups      = [aws_security_group.jenkins.id, aws_security_group.consul_servers.id]
  subnet_id            = module.infra.private_subnets_id[1]
  iam_instance_profile = aws_iam_instance_profile.jenkins_role_profile.name
  tags = {
    Name = "jenkins_server"
  }
}


resource "aws_instance" "jenkins_node" {
  count                = var.number_of_jenkins_nodes
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = aws_key_pair.project_key.key_name
  security_groups      = [aws_security_group.jenkins.id, aws_security_group.consul_servers.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins_role_profile.name
  subnet_id            = module.infra.private_subnets_id[count.index]
  tags = {
    Name = "jenkins_agent${count.index + 1}"
  }
}


resource "aws_iam_role" "jenkins_role" {
  name               = "jenkins_role"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

resource "aws_iam_policy_attachment" "jenkins_role_policy_attachment" {
  name       = "jenkins_role"
  roles      = [aws_iam_role.jenkins_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_instance_profile" "jenkins_role_profile" {
  name = "opsschool-jenkins_role"
  role = aws_iam_role.jenkins_role.name
}


resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = module.infra.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "ALB-jenkins" {
  subnets         = module.infra.public_subnets_id
  security_groups = [aws_security_group.jenkins-LB_SG.id]
  tags = {
    Name = "Loadbalncer"
  }
}

resource "aws_security_group" "jenkins-LB_SG" {
  name   = "jenkins-LB_SG"
  vpc_id = module.infra.vpc_id
}

resource "aws_lb_target_group" "jenkins_server" {
  name     = "ALB-jenkins"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.infra.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 60
  }
}

resource "aws_lb_listener" "listner8080" {
  load_balancer_arn = aws_lb.ALB-jenkins.arn
  port              = 8080
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_server.arn
  }
}

resource "aws_lb_target_group_attachment" "jenkins_server" {
  target_id        = aws_instance.jenkins_server.id
  target_group_arn = aws_lb_target_group.jenkins_server.id
}

resource "aws_security_group_rule" "LB_allow_8080" {
  description       = "allow http access from anywhere"
  from_port         = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.jenkins-LB_SG.id
  to_port           = 8080
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "jenkins-LB_out" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.jenkins-LB_SG.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "jenkins-LB" {
  value = aws_lb.ALB-jenkins.dns_name
}

output "jenkins_server" {
  value = aws_instance.jenkins_server.private_ip
}
output "jenkins_nodes" {
  value = aws_instance.jenkins_node.*.private_ip
}