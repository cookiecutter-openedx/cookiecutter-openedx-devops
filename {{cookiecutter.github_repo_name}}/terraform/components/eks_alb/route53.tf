#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create DNS records for EKS cluster load balancer
#------------------------------------------------------------------------------
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

data "kubernetes_service" "ingress_alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.k8s_namespace
  }
  depends_on = [module.alb_controller]
}

data "aws_elb_hosted_zone_id" "main" {}


resource "aws_route53_record" "naked" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = var.environment_domain
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_alb_controller.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "*.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_alb_controller.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}
