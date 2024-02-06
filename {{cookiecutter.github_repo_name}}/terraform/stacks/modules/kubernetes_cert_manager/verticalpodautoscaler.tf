locals {
  templatefile_vpa_cert_manager = templatefile("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager.yaml", {
  })

  templatefile_vpa_cert_manager_webhook = templatefile("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager-webhook.yaml", {
  })

  templatefile_vpa_cert_manager_cainjector = templatefile("${path.module}/manifests/verticalpodautoscalers/vpa-cert-manager-cainjector.yaml", {
  })

}
resource "kubernetes_manifest" "vpa-cert-manager" {
  manifest = yamldecode(local.templatefile_vpa_cert_manager)

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubernetes_manifest" "vpa-cert-manager-cainjector" {
  manifest = yamldecode(local.templatefile_vpa_cert_manager_cainjector)

  depends_on = [
    helm_release.cert-manager
  ]
}

resource "kubernetes_manifest" "vpa-cert-manager-webhook" {
  manifest = yamldecode(local.templatefile_vpa_cert_manager_webhook)
  depends_on = [
    helm_release.cert-manager
  ]
}
