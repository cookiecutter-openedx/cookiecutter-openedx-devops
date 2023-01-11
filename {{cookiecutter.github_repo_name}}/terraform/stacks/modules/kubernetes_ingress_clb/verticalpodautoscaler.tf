
data "template_file" "vpa-nginx" {
  template = file("${path.module}/yml/vpa-openedx-nginx.yaml.tpl")
  vars = {
    environment_namespace = var.stack_namespace
  }
}

resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.vpa-nginx.rendered
}
