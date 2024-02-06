
resource "kubernetes_manifest" "vpa-metrics-server" {
  manifest = yamldecode(templatefile("${path.module}/yml/verticalpodautoscalers/vpa-metrics-server.yaml", {}))

  depends_on = [
    helm_release.vpa
  ]
}
