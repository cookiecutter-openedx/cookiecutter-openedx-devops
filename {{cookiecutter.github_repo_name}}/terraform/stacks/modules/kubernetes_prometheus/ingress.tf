
resource "kubernetes_manifest" "ingress-grafana" {
  manifest = yamldecode(templatefile("${path.module}/yml/ingress-grafana.yml", {}))

  depends_on = [
    helm_release.prometheus
  ]
}
