#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#-----------------------------------------------------------
locals {

  templatefile_kubecost_ingress = templatefile("${path.module}/config/kubecost-ingress.yaml.tpl", {
    services_domain = var.services_subdomain
    subdomain       = "kubecost"
  })

}

resource "kubernetes_manifest" "ingress_kubecost" {
  manifest = yamldecode(local.templatefile_kubecost_ingress)

  depends_on = [
    helm_release.kubecost
  ]
}
