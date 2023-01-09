data "template_file" "vpa-cert-manager-cainjector" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-openedx-cert-manager-cainjector.yaml.tpl")
  vars = {
    environment_namespace = var.namespace
  }
}

data "template_file" "vpa-cert-manager-webhook" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-openedx-cert-manager-webhook.yaml.tpl")
  vars = {
    environment_namespace = var.namespace
  }
}

data "template_file" "vpa-cert-manager" {
  template = file("${path.module}/manifests/verticalpodautoscalers/vpa-openedx-cert-manager.yaml.tpl")
  vars = {
    environment_namespace = var.namespace
  }
}


resource "kubectl_manifest" "vpa-cert-manager" {
  yaml_body = data.template_file.vpa-cert-manager.rendered
}

resource "kubectl_manifest" "vpa-cert-manager-cainjector" {
  yaml_body = data.template_file.vpa-cert-manager-cainjector.rendered
}

resource "kubectl_manifest" "vpa-cert-manager-webhook" {
  yaml_body = data.template_file.vpa-cert-manager-webhook.rendered
}
