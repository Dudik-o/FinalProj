

resource "aws_instance" "grafana" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = module.infra.private_subnets_id[0]
  vpc_security_group_ids = [aws_security_group.grafana-sg.id, aws_security_group.consul_servers.id]
  key_name               = aws_key_pair.project_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  tags = {
    Name = "grafana"
  }
}


resource "aws_security_group" "grafana-sg" {
  name        = "grafana-sg"
  description = "security group for grafana server"
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
    from_port   = "3000"
    to_port     = "3000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_lb" "ALB-grafana" {
  subnets         = module.infra.public_subnets_id
  security_groups = [aws_security_group.grafana-LB_SG.id]
  tags = {
    Name = "grafana-Loadbalncer"
  }
}

resource "aws_security_group" "grafana-LB_SG" {
  name   = "grafana-LB_SG"
  vpc_id = module.infra.vpc_id
}

resource "aws_lb_target_group" "grafana_server" {
  name     = "ALB-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.infra.vpc_id
}

resource "aws_lb_listener" "listner3000" {
  load_balancer_arn = aws_lb.ALB-grafana.arn
  port              = 3000
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_server.arn
  }
}

resource "aws_lb_target_group_attachment" "grafana_server" {
  target_id        = aws_instance.grafana.id
  target_group_arn = aws_lb_target_group.grafana_server.id
}

resource "aws_security_group_rule" "LB_allow_3000" {
  description       = "allow http access from anywhere"
  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.grafana-LB_SG.id
  to_port           = 3000
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "grafana-LB_out" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.grafana-LB_SG.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "grafana-LB" {
  value = aws_lb.ALB-grafana.dns_name
}



output "grafana" {
  value = aws_instance.grafana.private_ip
}