
resource "kubectl_manifest" "vpa-metrics-server" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-metrics-server.yaml")

  depends_on = [
    helm_release.vpa
  ]
}
