
locals {
  templatefile_vpa_nginx = templatefile("${path.module}/yml/vpa-openedx-nginx.yaml", {})
}
resource "kubernetes_manifest" "nginx" {
  manifest = yamldecode(local.templatefile_vpa_nginx)
}
