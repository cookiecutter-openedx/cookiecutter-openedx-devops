#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module vertical pod autoscaler configuration
#------------------------------------------------------------------------------

locals {
  template_vpa_wordpress = templatefile("${path.module}/config/vpa-wordpress.yaml.tpl", {
    namespace = local.wordpressNamespace
  })
}

resource "kubernetes_manifest" "vpa-prometheus-operator" {
  manifest = yamldecode(local.template_vpa_wordpress)

  depends_on = [
    helm_release.wordpress
  ]
}
