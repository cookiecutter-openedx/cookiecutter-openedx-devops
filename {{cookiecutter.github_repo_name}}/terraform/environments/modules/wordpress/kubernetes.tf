#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress Kubernetes resources
#------------------------------------------------------------------------------

resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = local.wordpressNamespace
  }
}
