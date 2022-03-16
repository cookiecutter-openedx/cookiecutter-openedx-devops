

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}

resource "aws_route53_record" "master" {

  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "mongodb.master"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_docdb_cluster.default.endpoint}"]

}


resource "aws_route53_record" "replica" {

  zone_id = data.aws_route53_zone.environment_domain.id
  name    = "mongodb.replicas"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_docdb_cluster.default.reader_endpoint}"]

}
