
data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

resource "aws_route53_record" "bastion" {
  zone_id = data.aws_route53_zone.services_subdomain.id
  name    = "bastion.${var.services_subdomain}"
  type    = "A"
  ttl     = "600"


  records = [aws_eip.elasticip.public_ip]
}
