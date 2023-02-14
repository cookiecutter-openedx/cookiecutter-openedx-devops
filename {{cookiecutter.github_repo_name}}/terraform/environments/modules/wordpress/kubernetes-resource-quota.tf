#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: Wordpress Kubernetes resource quota
#------------------------------------------------------------------------------

data "template_file" "resource_quota" {
  template = file("${path.module}/config/resource-quota.yaml.tpl")
  vars = {
    namespace             = local.wordpressNamespace
    resource_quota_cpu    = var.resource_quota_cpu
    resource_quota_memory = var.resource_quota_memory
  }
}

resource "kubectl_manifest" "resource_quota" {
  count     = var.resource_quota == "Y" ? 1 : 0
  yaml_body = data.template_file.resource_quota.rendered

  depends_on = [
    kubernetes_secret.wordpress_config,
    ssh_sensitive_resource.mysql,
    kubernetes_namespace.wordpress,
    helm_release.wordpress
  ]
}
