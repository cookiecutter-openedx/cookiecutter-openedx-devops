#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create DNS records for EKS cluster load balancer
#------------------------------------------------------------------------------
data "aws_route53_zone" "admin_domain" {
  name = var.admin_domain
}
# to-do: remove this declaration and refactor references below from
# data.kubernetes_service.ingress_nginx_controller to
# helm_release.ingress_nginx_controller
data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "common-ingress-nginx-controller"
    namespace = "kube-system"
  }

  depends_on = [
    helm_release.ingress_nginx_controller
  ]
}

data "aws_elb_hosted_zone_id" "main" {}

# -------------------------------------------------------------------------------------
# setup DNS for root domain
# -------------------------------------------------------------------------------------
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_record" "root_naked" {
  zone_id = data.aws_route53_zone.root_domain.id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root_wildcard" {
  zone_id = data.aws_route53_zone.root_domain.id
  name    = "*.${var.root_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

# -------------------------------------------------------------------------------------
# setup DNS for admin subdomain
# -------------------------------------------------------------------------------------

resource "aws_route53_record" "admin_naked" {
  zone_id = data.aws_route53_zone.admin_domain.id
  name    = var.admin_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "admin_wildcard" {
  zone_id = data.aws_route53_zone.admin_domain.id
  name    = "*.${var.admin_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}
