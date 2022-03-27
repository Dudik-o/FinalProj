resource "aws_route53_zone" "kandula" {
  name = "kandula.com"

  vpc {
    vpc_id = module.infra.vpc_id
  }
}

resource "aws_route53_record" "prometheus_server" {
  zone_id = aws_route53_zone.kandula.id
  name    = "prometheus.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.prometheus.private_ip}"]
}




resource "aws_route53_record" "jenkins_server" {
  zone_id = aws_route53_zone.kandula.id
  name    = "jenkins_server.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jenkins_server.private_ip}"]
}

resource "aws_route53_record" "jenkins_node" {
  count                = var.number_of_jenkins_nodes
  zone_id = aws_route53_zone.kandula.id
  name    = "jenkins_node${count.index+1}.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.jenkins_node[count.index].private_ip}"]
}

resource "aws_route53_record" "consul_node" {
  count   = var.number_of_consul_servers
  zone_id = aws_route53_zone.kandula.id
  name    = "consul_server${count.index+1}.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.consul_servers[count.index].private_ip}"]
}

resource "aws_route53_record" "elastic" {
  zone_id = aws_route53_zone.kandula.id
  name    = "elastic.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.elastic.private_ip}"]
}

resource "aws_route53_record" "grafana" {
  zone_id = aws_route53_zone.kandula.id
  name    = "grafana.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.grafana.private_ip}"]
}

resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.kandula.id
  name    = "database.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.database.private_ip}"]
}

resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.kandula.id
  name    = "bastion.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_ip}"]
}

resource "aws_route53_record" "ansible-server" {
  zone_id = aws_route53_zone.kandula.id
  name    = "ansible.kandula.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ansible-server.private_ip}"]
}