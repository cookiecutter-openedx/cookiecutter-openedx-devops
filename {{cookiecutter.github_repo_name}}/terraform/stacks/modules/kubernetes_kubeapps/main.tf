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
#   helm show values bitnami/kubeapps
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

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes_kubeapps"
      "cookiecutter/resource/source"  = "charts.bitnami.com/bitnami/kubeapps"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_kubeapps }}"
    }
  )
}


data "template_file" "kubeapps-values" {
  template = file("${path.module}/yml/kubeapps-values.yaml")
}

resource "helm_release" "kubeapps" {
  namespace        = local.kubeapps_namespace
  create_namespace = false

  name       = "kubeapps"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "kubeapps"
  version    = "~> {{ cookiecutter.terraform_helm_kubeapps }}"

  # see https://docs.bitnami.com/kubernetes/infrastructure/kubeapps/configuration/expose-service/
  set {
    name  = "ingress.enabled"
    value = false
  }

  depends_on = [
    kubernetes_namespace.kubeapps
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter-terraform"
    namespace = local.kubeapps_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
