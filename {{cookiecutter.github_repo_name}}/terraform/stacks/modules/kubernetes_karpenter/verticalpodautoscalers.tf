
data "template_file" "karpenter" {
  template = file("${path.module}/yml/vpa-karpenter.yaml")
}

resource "kubectl_manifest" "nginx" {
  yaml_body = data.template_file.karpenter.rendered
}
