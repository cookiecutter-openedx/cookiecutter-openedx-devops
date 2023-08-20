#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2023
#
# usage: installs Descheduler for Kubernetes
# see: https://github.com/kubernetes-sigs/descheduler/blob/master/charts/descheduler/README.md
#      https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add descheduler https://kubernetes-sigs.github.io/descheduler/
#   helm repo update
#   helm search repo descheduler
#   helm show values descheduler/descheduler
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
locals {
  descheduler_namespace = "descheduler"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "openedx_devops/terraform/stacks/modules/kubernetes_descheduler"
      "cookiecutter/resource/source"  = "https://artifacthub.io/packages/helm/descheduler/descheduler"
      "cookiecutter/resource/version" = "0.27"
    }
  )
}

data "template_file" "descheduler-values" {
  template = file("${path.module}/yml/descheduler-values.yaml")
}


resource "helm_release" "descheduler" {
  namespace        = local.descheduler_namespace
  create_namespace = true

  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"

  version = "~> 0.27"

  values = [
    data.template_file.descheduler-values.rendered
  ]

}

#------------------------------------------------------------------------------
#                           SUPPORTING RESOURCES
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter-terraform"
    namespace = local.descheduler_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
