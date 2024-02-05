locals {
  templatefile_descheduler = templatefile("${path.module}/yml/vpa-descheduler.yaml", {})
}
resource "kubernetes_manifest" "descheduler" {
  manifest = yamldecode(local.templatefile_descheduler)

  depends_on = [
    helm_release.descheduler
  ]
}
