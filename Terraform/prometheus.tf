
## need to add Port of Consul ##


resource "aws_instance" "prometheus" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project_key.key_name
  subnet_id              = module.infra.private_subnets_id[1]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.prometheus-sg.id]
  tags = {
    Name = "prometheus"
  }
}

resource "aws_security_group" "prometheus-sg" {
  name        = "prometheus-sg"
  description = "security group for prometheus server"
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
    from_port   = "9100"
    to_port     = "9100"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "9090"
    to_port     = "9090"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_lb" "ALB-prometheus" {
  subnets         = module.infra.public_subnets_id
  security_groups = [aws_security_group.prometheus-LB_SG.id]
  tags = {
    Name = "prometheus-Loadbalncer"
  }
}

resource "aws_security_group" "prometheus-LB_SG" {
  name   = "prometheus-LB_SG"
  vpc_id = module.infra.vpc_id
}

resource "aws_lb_target_group" "prometheus_server" {
  name     = "ALB-prometheus"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = module.infra.vpc_id
}

resource "aws_lb_listener" "listner9090" {
  load_balancer_arn = aws_lb.ALB-prometheus.arn
  port              = 9090
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_server.arn
  }
}

resource "aws_lb_target_group_attachment" "prometheus_server" {
  target_id        = aws_instance.prometheus.id
  target_group_arn = aws_lb_target_group.prometheus_server.id
}

resource "aws_security_group_rule" "LB_allow_9090" {
  description       = "allow http access from anywhere"
  from_port         = 9090
  protocol          = "tcp"
  security_group_id = aws_security_group.prometheus-LB_SG.id
  to_port           = 9090
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "prometheus-LB_out" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.prometheus-LB_SG.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "prometheus-LB" {
  value = aws_lb.ALB-prometheus.dns_name
}



output "prometheus" {
  value = aws_instance.prometheus.private_ip
}