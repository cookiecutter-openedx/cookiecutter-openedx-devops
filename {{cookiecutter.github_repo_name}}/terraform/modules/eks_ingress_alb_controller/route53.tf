#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create subdomain records pointing to the ALB endpoint.
#------------------------------------------------------------------------------

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_zone" "subdomain" {
  count = length(var.subdomains)
  name  = "${element(var.subdomains, count.index)}.${var.environment_domain}"
}

resource "aws_route53_record" "subdomain-ns" {
  count   = length(var.subdomains)
  zone_id = data.aws_route53_zone.environment_domain.zone_id
  name    = "${element(var.subdomains, count.index)}.${var.environment_domain}"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.subdomain[count.index].name_servers
}

resource "aws_route53_record" "naked" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = var.environment_domain
  type    = "A"

  alias {
    name                   = kubernetes_ingress.nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_service.nginx,
    kubernetes_ingress.nginx
  ]
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "*.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = kubernetes_ingress.nginx.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_service.nginx,
    kubernetes_ingress.nginx
  ]
}
