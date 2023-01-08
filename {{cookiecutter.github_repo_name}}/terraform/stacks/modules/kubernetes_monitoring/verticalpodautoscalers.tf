
data "template_file" "vpa-cert-manager-cainjector" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager-cainjector.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-cert-manager-webhook" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager-webhook.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-cert-manager" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-cert-manager.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

data "template_file" "vpa-nginx" {
  template = file("${path.module}/yml/verticalpodautoscalers/vpa-openedx-nginx.yaml.tpl")
  vars = {
    environment_namespace = var.environment_namespace
  }
}

resource "kubectl_manifest" "cert-manager" {
  yaml_body = data.template_file.vpa-cert-manager.rendered

  depends_on = [
    helm_release.cert-manager,
    helm_release.vpa,
  ]
}

resource "kubectl_manifest" "cert-manager-cainjector" {
  yaml_body = data.template_file.vpa-cert-manager-cainjector.rendered

  depends_on = [
    helm_release.cert-manager,
    helm_release.vpa,
  ]
}

resource "kubectl_manifest" "cert-manager-webhook" {
  yaml_body = data.template_file.vpa-cert-manager-webhook.rendered

  depends_on = [
    helm_release.cert-manager,
    helm_release.vpa,
  ]
}

resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.vpa-nginx.rendered

  depends_on = [
    helm_release.vpa,
  ]
}
