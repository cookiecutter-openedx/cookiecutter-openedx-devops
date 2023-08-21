#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module vertical pod autoscaler configuration
#------------------------------------------------------------------------------

data "template_file" "vpa_wordpress" {
  template = file("${path.module}/config/vpa-wordpress.yaml.tpl")
  vars = {
    namespace = local.wordpressNamespace
  }
}

resource "kubernetes_manifest" "vpa-prometheus-operator" {
  manifest = yamldecode(data.template_file.vpa_wordpress.rendered)

  depends_on = [
    helm_release.wordpress
  ]
}
