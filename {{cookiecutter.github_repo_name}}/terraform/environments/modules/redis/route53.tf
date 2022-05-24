
data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    Namespace = var.environment_namespace
  }
}

resource "aws_route53_record" "primary" {

  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "redis.primary"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.redis.primary_endpoint_address}"]

}
