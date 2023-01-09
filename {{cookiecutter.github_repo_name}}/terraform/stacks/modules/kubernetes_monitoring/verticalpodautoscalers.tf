
data "template_file" "vpa-nginx" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-nginx.yaml.tpl")
  vars = {
    environment_namespace = var.stack_namespace
  }
}


resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.vpa-nginx.rendered

  depends_on = [
    helm_release.vpa,
  ]
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
