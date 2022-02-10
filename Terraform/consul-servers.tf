resource "aws_instance" "consul_servers" {
  count                  = var.number_of_consul_servers
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project_key.key_name
  subnet_id              = module.infra.private_subnets_id[count.index % 2]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.consul_servers.id]

  tags = {
    Name          = "consul_server${count.index + 1}"
    consul_server = "true"
  }
}

resource "aws_security_group" "consul" {
  name   = "consul"
  vpc_id = module.infra.vpc_id
}

resource "aws_security_group" "consul_servers" {
  name        = "consul_servers"
  description = "Allow ssh & consul inbound traffic"
  vpc_id      = module.infra.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all inside security group"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh from the world"
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow consul UI access from the world"
  }
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow agent join from the world"
  }

  ingress {
  from_port   = 8302
  to_port     = 8302
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow agent join from the world"
  }

 ingress {
  from_port   = 8600
  to_port     = 8600
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow DNS"
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow service registration from the world"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outside security group"
  }
}

output "consul_servers" {
  value = aws_instance.consul_servers.*.private_ip
}



resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}


resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}


resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}


resource "aws_iam_instance_profile" "consul-join" {
  name = "opsschool-consul-join"
  role = aws_iam_role.consul-join.name
}

resource "aws_lb" "ALB" {
  subnets         = module.infra.public_subnets_id
  security_groups = [aws_security_group.LB_SG.id]
  tags = {
    Name = "Loadbalncer"
  }
}


resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = 8500
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_servers.arn
  }
}


resource "aws_lb_target_group" "consul_servers" {
  name     = "ALB"
  port     = 8500
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

resource "aws_lb_target_group_attachment" "consul" {
  count            = var.number_of_consul_servers
  target_id        = aws_instance.consul_servers.*.id[count.index]
  target_group_arn = aws_lb_target_group.consul_servers.arn
}

resource "aws_security_group" "LB_SG" {
  name   = "LB_SG"
  vpc_id = module.infra.vpc_id
}

resource "aws_security_group_rule" "LB_allow_http" {
  description       = "allow http access from anywhere"
  from_port         = 8500
  protocol          = "tcp"
  security_group_id = aws_security_group.LB_SG.id
  to_port           = 8500
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "LB_out" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.LB_SG.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

output "Consul-LB" {
  value = aws_lb.ALB.dns_name
}