resource "kubernetes_manifest" "vpa-prometheus-kube-state-metrics" {
  manifest = yamldecode(templatefile("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-kube-state-metrics.yaml", {}))

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubernetes_manifest" "vpa-prometheus-grafana" {
  manifest = yamldecode(templatefile("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-grafana.yaml", {}))

  depends_on = [
    helm_release.prometheus
  ]
}

resource "kubernetes_manifest" "vpa-prometheus-operator" {
  manifest = yamldecode(templatefile("${path.module}/yml/verticalpodautoscalers/vpa-prometheus-operator.yaml", {}))

  depends_on = [
    helm_release.prometheus
  ]
}
