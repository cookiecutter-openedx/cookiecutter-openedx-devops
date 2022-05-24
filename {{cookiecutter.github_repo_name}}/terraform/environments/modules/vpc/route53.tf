#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Apr-2022
#
# usage: Add DNS records.
#------------------------------------------------------------------------------

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

resource "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = var.tags
}

resource "aws_route53_record" "environment_domain-ns" {
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = aws_route53_zone.environment_domain.name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.environment_domain.name_servers
}
