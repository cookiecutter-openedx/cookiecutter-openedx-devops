#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module vertical pod autoscaler configuration
#------------------------------------------------------------------------------

data "template_file" "vpa-wordpress" {
  template = file("${path.module}/config/vpa-wordpress.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace,
    helm_release.wordpress
  }
}
