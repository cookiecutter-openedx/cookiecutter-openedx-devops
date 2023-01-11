
resource "kubectl_manifest" "ingress-grafana" {
  yaml_body = file("${path.module}/yml/ingress-grafana.yml")
}
