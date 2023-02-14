#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module DNS record
#------------------------------------------------------------------------------
data "aws_elb_hosted_zone_id" "main" {}

data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "common-ingress-nginx-controller"
    namespace = "kube-system"
  }
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "wordpress_domain" {
  zone_id = local.wordpressHostedZoneID
}


resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.wordpress_domain.id
  name    = local.wordpressDomain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}

resource "aws_route53_record" "phpmyadmin" {
  count   = var.phpmyadmin == "Y" ? 1 : 0
  zone_id = data.aws_route53_zone.wordpress_domain.id
  name    = "phpmyadmin.${local.wordpressDomain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}
