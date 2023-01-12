
data "aws_route53_zone" "services_subdomain" {
  name = var.root_domain
}

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.services_subdomain.id
  name    = "bastion.${var.root_domain}"
  type    = "A"
  ttl     = "600"


  records = [aws_eip.elasticip.public_ip]
}
