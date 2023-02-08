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
    environment_namespace = local.wordpressNamespace
  }
}

resource "kubectl_manifest" "vpa-prometheus-operator" {
  yaml_body = data.template_file.vpa_wordpress.rendered

  depends_on = [
    helm_release.wordpress
  ]
}
