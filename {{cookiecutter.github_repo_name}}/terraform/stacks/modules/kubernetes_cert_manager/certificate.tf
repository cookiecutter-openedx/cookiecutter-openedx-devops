locals {
  templatefile_certificate = templatefile("${path.module}/manifests/certificate.yml.tpl", {
    services_subdomain = var.services_subdomain
    namespace          = var.namespace
  })

}
data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

resource "kubernetes_manifest" "certificate" {
  manifest = yamldecode(local.templatefile_certificate)

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_iam_policy.cert_manager_policy,
  ]
}
