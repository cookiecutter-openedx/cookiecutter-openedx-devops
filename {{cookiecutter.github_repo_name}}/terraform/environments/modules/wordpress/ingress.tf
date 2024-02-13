#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress ingress
#------------------------------------------------------------------------------

locals {
  template_wordpress_ingress = templatefile("${path.module}/config/wordpress-ingress.yml.tpl", {
    name           = local.wordpressDomain
    namespace      = local.wordpressNamespace
    cluster_issuer = local.wordpressDomain
    domain         = local.wordpressDomain
  })

  template_phpmyadmin_ingress = templatefile("${path.module}/config/phpmyadmin-ingress.yml.tpl", {
    name           = "phpmyadmin.${local.wordpressDomain}"
    namespace      = local.wordpressNamespace
    cluster_issuer = local.wordpressDomain
    domain         = "phpmyadmin.${local.wordpressDomain}"
  })
}
resource "kubernetes_manifest" "wordpress_ingress" {
  manifest = yamldecode(local.template_wordpress_ingress)

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}

resource "kubernetes_manifest" "phpmyadmin" {
  count    = var.phpmyadmin == "Y" ? 1 : 0
  manifest = yamldecode(local.template_phpmyadmin_ingress)

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress,
    helm_release.phpmyadmin,
    kubernetes_manifest.wordpress_ingress
  ]
}
