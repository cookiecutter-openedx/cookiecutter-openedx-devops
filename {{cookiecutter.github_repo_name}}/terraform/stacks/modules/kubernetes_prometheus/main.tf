#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Prometheus monitoring.
#
# see:  https://prometheus.io/
#       https://grafana.com/
#       https://prometheus-operator.dev/docs/prologue/quick-start/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts/
#   helm repo update
#   helm search repo prometheus-community
#   helm show values prometheus-community/kube-prometheus-stack
#
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#
# in the event of install problems, first try running these in
# order to elminate any existing CRDs:
#   kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
#   kubectl delete crd alertmanagers.monitoring.coreos.com
#   kubectl delete crd podmonitors.monitoring.coreos.com
#   kubectl delete crd probes.monitoring.coreos.com
#   kubectl delete crd prometheuses.monitoring.coreos.com
#   kubectl delete crd prometheusrules.monitoring.coreos.com
#   kubectl delete crd servicemonitors.monitoring.coreos.com
#   kubectl delete crd thanosrulers.monitoring.coreos.com
#-----------------------------------------------------------
locals {
  templatefile_prometheus_values = templatefile("${path.module}/yml/prometheus-values.yaml", {})
  cost_analyzer                  = "cost-analyzer"
  prometheus                     = "prometheus"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "openedx_devops/terraform/stacks/modules/kubernetes_prometheus"
      "cookiecutter/resource/source"  = "prometheus-community.github.io/helm-charts/kube-prometheus-stack"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_prometheus }}"
    }
  )
}


resource "helm_release" "prometheus" {
  namespace        = local.prometheus
  create_namespace = true

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "{{ cookiecutter.terraform_helm_prometheus }}"

  values = [
    local.templatefile_prometheus_values
  ]

  # changes the password (stored in k8s secret prometheus-grafana) from 'prom-operator'
  # to our own randomly generated 16-character strong password.
  set {
    name  = "grafana.adminPassword"
    value = random_password.grafana.result
  }

}

#------------------------------------------------------------------------------
#                               SUPPORTING RESOURCES
#------------------------------------------------------------------------------
resource "random_password" "grafana" {
  length  = 16
  special = false
  keepers = {
    version = "1"
  }
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
    namespace = local.prometheus
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
