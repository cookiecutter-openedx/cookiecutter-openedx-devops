#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress ssl certs for ingress
#------------------------------------------------------------------------------

locals {
  template_cluster_issuer = templatefile("${path.module}/config/cluster-issuer.yml.tpl", {
    root_domain      = local.wordpressRootDomain
    wordpress_domain = local.wordpressDomain
    aws_region       = var.aws_region
    hosted_zone_id   = data.aws_route53_zone.wordpress_domain.id
  })
}
resource "kubernetes_manifest" "cluster-issuer" {
  manifest = yamldecode(local.template_cluster_issuer)

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}
