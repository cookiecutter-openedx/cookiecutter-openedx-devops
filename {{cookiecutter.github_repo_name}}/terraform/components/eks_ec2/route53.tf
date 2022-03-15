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
    name                   = data.kubernetes_service.ingress_nginx_controller.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "*.${var.environment_domain}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.ingress_nginx_controller.load_balancer_ingress.0.hostname
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}

