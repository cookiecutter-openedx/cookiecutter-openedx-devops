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
#
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------

resource "helm_release" "prometheus" {
  namespace        = "monitoring"
  create_namespace = true

  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "39.6.0"

  # un-comment to include a yaml manifest with configuration overrides.
  # To generate a yaml file with all possible configuration options:
  #     helm show values prometheus-community/kube-prometheus-stack > ./yml/values.yaml
  #
  #values = [
  #  "${file("${path.module}/yml/values.yaml")}"
  #]

  depends_on = [
    helm_release.metrics_server
  ]
}
