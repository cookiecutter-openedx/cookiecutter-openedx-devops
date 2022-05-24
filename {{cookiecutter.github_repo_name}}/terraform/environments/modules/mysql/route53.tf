#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
#------------------------------------------------------------------------------

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
  tags = {
    Namespace = var.environment_namespace
  }
}

resource "aws_route53_record" "mysql" {

  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "mysql"
  type    = "CNAME"
  ttl     = "300"
  records = ["${data.kubernetes_secret.mysql_root.data.MYSQL_HOST}"]

}
