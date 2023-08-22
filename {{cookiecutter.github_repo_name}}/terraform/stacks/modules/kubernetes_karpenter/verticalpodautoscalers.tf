
data "template_file" "vpa-karpenter" {
  template = file("${path.module}/yml/vpa-karpenter.yaml")
  vars = {
  }
}

resource "kubernetes_manifest" "vpa-karpenter" {
  manifest = yamldecode(data.template_file.vpa-karpenter.rendered)

  depends_on = [
    helm_release.karpenter
  ]
}
