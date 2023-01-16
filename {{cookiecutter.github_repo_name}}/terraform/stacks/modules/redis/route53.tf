
data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.services_subdomain.id
  name    = "redis.primary"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.redis.primary_endpoint_address}"]
}
