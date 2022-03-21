#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add nginx proxy for EKS cluster load balancer
#
# see:
# - https://kubernetes.github.io/ingress-nginx/
# - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
#------------------------------------------------------------------------------
locals {
  external_dns_annotation = "*.${var.environment_domain}"
}

resource "helm_release" "ingress-nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "{{ cookiecutter.terraform_helm_ingress_nginx }}"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  depends_on = [module.eks]
}

data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.ingress-nginx]
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "ingress_domains_wildcard" {
  count   = length(var.subdomains)
  zone_id = aws_route53_zone.subdomain[count.index].id
  name    = "*.${element(var.subdomains, count.index)}.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ingress_domains_naked" {
  count   = length(var.subdomains)
  zone_id = aws_route53_zone.subdomain[count.index].id
  name    = "${element(var.subdomains, count.index)}.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}
