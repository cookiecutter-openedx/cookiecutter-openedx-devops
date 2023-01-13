#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Jan-2023
#
# usage: installs kubeapps
# see: https://kubeapps.dev/docs/latest/tutorials/getting-started/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add bitnami https://charts.bitnami.com/bitnami
#   helm repo update
#   helm search repo bitnami/kubeapps
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# To generate the web app sign-in token:
#   kubectl get --namespace kubeapps secret kubeapps-admin -o go-template='{% raw %}{{.data.token | base64decode}}{% endraw %}'
#-----------------------------------------------------------
locals {
  kubeapps_namespace        = "kubeapps"
  kubeapps_account_name     = "kubeapps-admin"
  kubeapps_ingress_hostname = "${local.kubeapps_namespace}.${var.services_subdomain}"
}


resource "helm_release" "kubeapps" {
  namespace        = local.kubeapps_namespace
  create_namespace = false

  name       = "kubeapps"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"
  # FIX NOTE: what is the semantic version for this?
  #version    = "{{ cookiecutter.terraform_helm_kubeapps }}"

  # see https://docs.bitnami.com/kubernetes/infrastructure/kubeapps/configuration/expose-service/
  set {
    name  = "ingress.enabled"
    value = false
  }

  depends_on = [
    kubernetes_namespace.kubeapps
  ]
}
