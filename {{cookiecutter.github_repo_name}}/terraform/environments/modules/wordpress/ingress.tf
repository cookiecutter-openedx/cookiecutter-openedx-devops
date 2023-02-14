#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress ingress
#------------------------------------------------------------------------------

data "template_file" "wordpress_ingress" {
  template = file("${path.module}/config/wordpress-ingress.yml.tpl")
  vars = {
    name           = local.wordpressDomain
    namespace      = local.wordpressNamespace
    cluster_issuer = local.wordpressDomain
    domain         = local.wordpressDomain
  }
}

resource "kubectl_manifest" "wordpress_ingress" {
  yaml_body = data.template_file.wordpress_ingress.rendered

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}


data "template_file" "phpmyadmin_ingress" {
  template = file("${path.module}/config/phpmyadmin-ingress.yml.tpl")
  vars = {
    name           = "phpmyadmin.${local.wordpressDomain}"
    namespace      = local.wordpressNamespace
    cluster_issuer = local.wordpressDomain
    domain         = "phpmyadmin.${local.wordpressDomain}"
  }
}

resource "kubectl_manifest" "phpmyadmin" {
  count     = var.phpmyadmin == "Y" ? 1 : 0
  yaml_body = data.template_file.phpmyadmin_ingress.rendered

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress,
    helm_release.phpmyadmin,
    kubectl_manifest.wordpress_ingress
  ]
}
