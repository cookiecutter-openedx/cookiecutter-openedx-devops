
locals {
  template_certificate = templatefile("${path.module}/manifests/certificate.yml.tpl", {
    environment_domain = var.environment_domain
    namespace          = var.environment_namespace
  })

  template_cluster_issuer = templatefile("${path.module}/manifests/cluster-issuer.yml.tpl", {
    root_domain        = var.root_domain
    environment_domain = var.environment_domain
    namespace          = var.environment_namespace
    aws_region         = var.aws_region
    hosted_zone_id     = data.aws_route53_zone.environment_domain.id
  })
}

resource "kubernetes_manifest" "cluster-issuer" {
  manifest = yamldecode(local.template_cluster_issuer)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubernetes_manifest" "certificate" {
  manifest = yamldecode(local.template_certificate)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}
