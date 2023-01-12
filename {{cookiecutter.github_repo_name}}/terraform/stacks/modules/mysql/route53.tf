
locals {
  host_name = "mysql.${var.services_subdomain}"
}


data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

resource "aws_route53_record" "mysql" {
  zone_id = data.aws_route53_zone.services_subdomain.id
  name    = local.host_name
  type    = "CNAME"
  ttl     = "600"
  records = [module.db.db_instance_address]
}
