data "template_file" "vpa-cert-manager" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager.yaml")
}

data "template_file" "vpa-cert-manager-webhook" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager-webhook.yaml")
}

data "template_file" "vpa-cert-manager-cainjector" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager-cainjector.yaml")
}


resource "kubectl_manifest" "vpa-cert-manager" {
  yaml_body = data.template_file.vpa-cert-manager.rendered

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubectl_manifest" "vpa-cert-manager-cainjector" {
  yaml_body = data.template_file.vpa-cert-manager-cainjector.rendered

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubectl_manifest" "vpa-cert-manager-webhook" {
  yaml_body = data.template_file.vpa-cert-manager-webhook.rendered
  depends_on = [
    helm_release.cert-manager
  ]
}
