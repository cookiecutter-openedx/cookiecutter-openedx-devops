locals {
  templatefile_cluster_issuer = templatefile("${path.module}/manifests/cluster-issuer.yml.tpl", {
    root_domain        = var.root_domain
    services_subdomain = var.services_subdomain
    namespace          = var.namespace
    aws_region         = var.aws_region
    hosted_zone_id     = data.aws_route53_zone.services_subdomain.id
  })
}

resource "kubernetes_manifest" "cluster-issuer" {
  manifest = yamldecode(local.templatefile_cluster_issuer)

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_iam_policy.cert_manager_policy,
  ]
}
