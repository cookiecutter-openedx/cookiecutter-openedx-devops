#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#-----------------------------------------------------------

data "template_file" "kubecost_ingress" {
  template = file("${path.module}/config/kubecost-ingress.yaml.tpl")
  vars = {
    services_domain = var.services_subdomain
    subdomain       = "kubecost"
  }
}

resource "kubectl_manifest" "ingress_kubecost" {
  yaml_body = data.template_file.kubecost_ingress.rendered

  depends_on = [
    helm_release.kubecost
  ]
}
