#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module ingress
#------------------------------------------------------------------------------

data "template_file" "ingress" {
  template = file("${path.module}/yml/ingress-wordpress.yaml.tpl")
  vars = {
    wordpress_namespace   = var.wordpress_namespace
    wordpress_domain      = var.wordpress_domain
  }
}

resource "kubectl_manifest" "ingress_wordpress" {
  yaml_body = data.template_file.ingress.rendered
}

data "template_file" "cluster-issuer" {
  template = file("${path.module}/yml/cluster-issuer.yml.tpl")
  vars = {
    root_domain         = var.root_domain
    wordpress_domain    = var.wordpress_domain
    namespace           = var.wordpress_namespace
    aws_region          = var.aws_region
    hosted_zone_id      = data.aws_route53_zone.environment_domain.id
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = data.template_file.cluster-issuer.rendered
}
