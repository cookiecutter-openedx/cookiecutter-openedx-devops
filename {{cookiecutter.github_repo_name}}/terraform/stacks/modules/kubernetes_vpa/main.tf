#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs the Kubernetes Vertical Pod Autoscaler.
#
# see:  https://www.datree.io/helm-chart/vertical-pod-autoscaler-helm
#       https://www.youtube.com/watch?v=jcHQ5SKKTLM
#       https://artifacthub.io/packages/helm/fairwinds-stable/goldilocks
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add cowboysysop https://cowboysysop.github.io/charts/
#   helm repo update
#   helm search repo cowboysysop
#   helm show values cowboysysop/vertical-pod-autoscaler
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
locals {

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes_vpa"
      "cookiecutter/resource/source"  = "cowboysysop.github.io/charts/vertical-pod-autoscaler"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_vertical_pod_autoscaler }}"
    }
  )

}
data "template_file" "vertical-pod-autoscaler-values" {
  template = file("${path.module}/yml/vertical-pod-autoscaler-values.yaml")
  vars     = {}
}

resource "helm_release" "vpa" {
  namespace        = "vpa"
  create_namespace = true

  name       = "vertical-pod-autoscaler"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = "~> {{ cookiecutter.terraform_helm_vertical_pod_autoscaler }}"

  values = [
    data.template_file.vertical-pod-autoscaler-values.rendered
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
    name      = "cookiecutter"
    namespace = var.cert_manager_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
