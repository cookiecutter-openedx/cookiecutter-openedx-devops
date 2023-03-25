#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2023
#
# usage: Add DNS records for AWS SES Identity Verification.
#------------------------------------------------------------------------------
data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

resource "aws_ses_domain_identity" "environment_domain" {
  domain = var.environment_domain
}

resource "aws_route53_record" "aws_ses_domain_identity" {
  zone_id = data.aws_route53_zone.environment_domain.zone_id
  name    = "_amazonses.${var.environment_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.environment_domain.verification_token]
}
