resource "kubectl_manifest" "vpa-prometheus-kube-state-metrics" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-kube-state-metrics.yaml")

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "vpa-prometheus-grafana" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-grafana.yaml")

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubectl_manifest" "vpa-prometheus-operator" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-operator.yaml")

  depends_on = [
    helm_release.prometheus
  ]
}
