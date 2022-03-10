
resource "aws_instance" "elastic" {
  ami                    = "ami-0cc01dc1dd19d98c2"
  instance_type          = "t3.medium"
  subnet_id              = module.infra.private_subnets_id[1]
  vpc_security_group_ids = [aws_security_group.elastic-sg.id, aws_security_group.consul_servers.id]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  key_name               = aws_key_pair.project_key.key_name
  tags = {
    Name = "elastic"
  }
}


resource "aws_security_group" "elastic-sg" {
  name        = "elastic-sg"
  description = "security group for elastic server"
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
    from_port   = "9200"
    to_port     = "9200"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "9300"
    to_port     = "9300"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = "5601"
    to_port     = "5601"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "5044"
    to_port     = "5044"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "elastic-ALB" {
  subnets         = module.infra.public_subnets_id
  security_groups = [aws_security_group.elastic-LB_SG.id]
  tags = {
    Name = "Loadbalncer"
  }
}


resource "aws_lb_listener" "elastic-listner" {
  load_balancer_arn = aws_lb.elastic-ALB.arn
  port              = 5601
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elastic.arn
  }
}


resource "aws_lb_target_group" "elastic" {
  name     = "elastic-ALB"
  port     = 5601
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

resource "aws_lb_target_group_attachment" "elastic" {
  target_id        = aws_instance.elastic.id
  target_group_arn = aws_lb_target_group.elastic.arn
}

resource "aws_security_group" "elastic-LB_SG" {
  name   = "elastic-LB_SG"
  vpc_id = module.infra.vpc_id
}

resource "aws_security_group_rule" "elastic-LB_allow_http" {
  description       = "allow http access from anywhere"
  from_port         = 5601
  protocol          = "tcp"
  security_group_id = aws_security_group.elastic-LB_SG.id
  to_port           = 5601
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "elastic-LB_out" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.elastic-LB_SG.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "elastic-LB" {
  value = aws_lb.elastic-ALB.dns_name
}


output "elastic" {
  value = aws_instance.elastic.private_ip
}