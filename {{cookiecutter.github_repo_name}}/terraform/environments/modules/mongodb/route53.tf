#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: aug-2022
#
# usage: create environment connection resources for remote MongoDB instance.
#------------------------------------------------------------------------------

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    "cookiecutter/environment_namespace" = var.environment_namespace
  }
}

resource "aws_route53_record" "mongodb" {

  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "mongodb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${data.kubernetes_secret.mongodb_admin.data.MONGODB_HOST}"]

}
