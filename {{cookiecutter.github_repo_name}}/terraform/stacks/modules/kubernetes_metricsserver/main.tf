#------------------------------------------------------------------------------
#
# see: https://github.com/kubernetes-sigs/metrics-server
#
#------------------------------------------------------------------------------

#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Kubernetes metrics-server.
#
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
#   helm repo update
#   helm search repo metrics-server
#   helm show values metrics-server/metrics-server
#-----------------------------------------------------------
locals {
  templatefile_metrics_server_values = templatefile("${path.module}/config/metrics-server-values.yaml", {})


  metrics_server = "metrics-server"
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes_metricsserver"
      "cookiecutter/resource/source"  = "kubernetes-sigs.github.io/metrics-server/"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_metrics_server }}"
    }
  )

}
resource "helm_release" "metrics_server" {
  namespace        = local.metrics_server
  create_namespace = true

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "~> {{ cookiecutter.terraform_helm_metrics_server }}"

  values = [
    local.templatefile_metrics_server_values
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
    namespace = local.metrics_server
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
