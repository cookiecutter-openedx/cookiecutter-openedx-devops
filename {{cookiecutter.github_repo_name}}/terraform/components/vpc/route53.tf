#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------

#   un-comment this if the root_domain is managed in route53
# -----------------------------------------------------------------------------
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
