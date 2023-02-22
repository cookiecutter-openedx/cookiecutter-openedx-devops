#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add cost-analyzer https://kubecost.github.io/cost-analyzer/
#   helm repo update
#   helm search repo cost-analyzer
#   helm show values cost-analyzer/cost-analyzer
#-----------------------------------------------------------
locals {
  cost_analyzer = "cost-analyzer"
}

data "template_file" "kubecost-values" {
  template = file("${path.module}/config/kubecost-values.yaml")
  vars = {
    # get a free Kubecost token here:
    # https://www.kubecost.com/install#show-instructions
    kubecostToken = "set-me-please"
  }
}

resource "helm_release" "kubecost" {
  name             = local.cost_analyzer
  namespace        = "kubecost"
  create_namespace = true

  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = "{{ cookiecutter.terraform_helm_kubecost }}"

  values = [
    data.template_file.kubecost-values.rendered
  ]

}
