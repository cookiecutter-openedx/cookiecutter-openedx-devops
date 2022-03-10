#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add nginx proxy for EKS cluster load balancer
#------------------------------------------------------------------------------ 
locals {
  external_dns_annotation = "*.${var.environment_domain}"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "helm_release" "nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "3.34.0"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

data "kubernetes_service" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.nginx]
}

data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "ingress_domains_wildcard" {
  count   = length(var.subdomains)
  zone_id = aws_route53_zone.subdomain[count.index].id
  name    = "*.${element(var.subdomains, count.index)}.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.load_balancer_ingress.0.hostname
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
    name                   = data.kubernetes_service.ingress_nginx_controller.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}


