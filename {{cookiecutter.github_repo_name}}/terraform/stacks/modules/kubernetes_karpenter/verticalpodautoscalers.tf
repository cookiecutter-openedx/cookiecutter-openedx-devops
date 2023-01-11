
data "template_file" "karpenter" {
  template = file("${path.module}/yml/vpa-karpenter.yaml")
}

resource "kubectl_manifest" "karpenter" {
  yaml_body = data.template_file.karpenter.rendered

  depends_on = [
    helm_release.karpenter
  ]
}
