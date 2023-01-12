data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

resource "aws_route53_record" "mongodb" {
  zone_id = data.aws_route53_zone.services_subdomain.id
  name    = local.host_name
  type    = "A"
  ttl     = "600"
  records = [aws_instance.mongodb.private_ip]
}
