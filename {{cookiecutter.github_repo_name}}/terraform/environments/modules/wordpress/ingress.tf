#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress ingress
#------------------------------------------------------------------------------

data "template_file" "ingress" {
  template = file("${path.module}/config/ingress.yml.tpl")
  vars = {
    name           = local.wordpress
    namespace      = local.wordpressNamespace
    cluster_issuer = local.wordpressDomain
    root_domain    = local.wordpressRootDomain
    domain         = local.wordpressDomain
  }
}

resource "kubectl_manifest" "ingress" {
  yaml_body = data.template_file.ingress.rendered

  depends_on = [
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}
