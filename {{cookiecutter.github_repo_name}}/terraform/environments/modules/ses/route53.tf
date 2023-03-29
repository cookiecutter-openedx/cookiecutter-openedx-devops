#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:   apr-2023
#
# usage:  Add DNS records for AWS SES Identity Verification.
#------------------------------------------------------------------------------
data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}


resource "aws_route53_record" "aws_ses_domain_identity" {
  zone_id = data.aws_route53_zone.environment_domain.zone_id
  name    = "_amazonses.${var.environment_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.environment_domain.verification_token]
}

resource "aws_route53_record" "environment_domain_amazonses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.environment_domain.zone_id
  name    = "${aws_ses_domain_dkim.environment_domain.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.environment_domain.dkim_tokens[count.index]}.dkim.amazonses.com"]
}
