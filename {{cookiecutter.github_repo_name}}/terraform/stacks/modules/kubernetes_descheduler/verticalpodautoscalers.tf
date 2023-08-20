
data "template_file" "descheduler" {
  template = file("${path.module}/yml/vpa-descheduler.yaml")
}

resource "kubernetes_manifest" "descheduler" {
  manifest = yamldecode(data.template_file.descheduler.rendered)

  depends_on = [
    helm_release.descheduler
  ]
}
