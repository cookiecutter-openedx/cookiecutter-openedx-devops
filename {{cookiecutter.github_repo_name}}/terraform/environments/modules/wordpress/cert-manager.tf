#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress ssl certs for ingress
#------------------------------------------------------------------------------

data "template_file" "cluster-issuer" {
  template = file("${path.module}/config/cluster-issuer.yml.tpl")
  vars = {
    root_domain         = var.root_domain
    wordpress_domain    = var.wordpressConfig["Domain"]
    namespace           = var.wordpressConfig["Namespace"]
    aws_region          = var.aws_region
    hosted_zone_id      = data.aws_route53_zone.environment_domain.id
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = data.template_file.cluster-issuer.rendered

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}
