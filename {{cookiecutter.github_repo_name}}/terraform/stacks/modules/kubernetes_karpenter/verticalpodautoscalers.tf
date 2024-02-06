
locals {
  templatefile_karpenter = templatefile("${path.module}/yml/vpa-karpenter.yaml", {})
}

resource "kubernetes_manifest" "karpenter" {
  manifest = yamldecode(local.templatefile_karpenter)

  depends_on = [
    helm_release.karpenter
  ]
}
