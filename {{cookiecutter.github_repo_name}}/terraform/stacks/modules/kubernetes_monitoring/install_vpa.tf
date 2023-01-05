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
#
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
resource "helm_release" "vpa" {
  namespace        = "monitoring"
  create_namespace = true

  name       = "vertical-pod-autoscaler"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = "5.1.1"

}

resource "kubectl_manifest" "vpa-prometheus-kube-state-metrics" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-kube-state-metrics.yaml")

  depends_on = [
    helm_release.vpa,
    helm_release.prometheus
  ]
}
resource "kubectl_manifest" "vpa-prometheus-grafana" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-grafana.yaml")

  depends_on = [
    helm_release.vpa,
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "vpa-prometheus-operator" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-operator.yaml")

  depends_on = [
    helm_release.vpa,
    helm_release.prometheus
  ]
}
