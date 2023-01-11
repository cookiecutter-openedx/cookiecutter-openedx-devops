
resource "kubectl_manifest" "ingress-grafana" {
  yaml_body = file("${path.module}/yml/ingress-grafana.yml")

  depends_on = [
    helm_release.prometheus
  ]
}
