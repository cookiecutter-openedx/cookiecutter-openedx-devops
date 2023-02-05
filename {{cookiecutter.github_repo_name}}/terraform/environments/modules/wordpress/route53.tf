#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module DNS record
#------------------------------------------------------------------------------
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    "cookiecutter/environment_namespace" = var.environment_namespace
  }
}

resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = var.wordpress_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}
