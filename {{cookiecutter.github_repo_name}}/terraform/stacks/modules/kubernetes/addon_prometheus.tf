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
    module.eks,
  ]
}

resource "kubectl_manifest" "vpa-prometheus-kube-state-metrics" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-kube-state-metrics.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa,
    helm_release.prometheus
  ]
}
resource "kubectl_manifest" "vpa-prometheus-grafana" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-grafana.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa,
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "vpa-prometheus-operator" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-operator.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa,
    helm_release.prometheus
  ]
}
