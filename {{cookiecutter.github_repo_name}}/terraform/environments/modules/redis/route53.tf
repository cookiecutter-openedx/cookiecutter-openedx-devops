
data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    "cookiecutter/environment_namespace" = var.environment_namespace
  }
}

data "kubernetes_secret" "service_redis" {
  metadata {
    name      = "redis"
    namespace = var.shared_resource_namespace
  }
}

resource "aws_route53_record" "redis_primary" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "redis.primary"
  type    = "CNAME"
  ttl     = "300"
  records = ["${data.kubernetes_secret.service_redis.data.REDIS_HOST}"]
}
