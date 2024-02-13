locals {
  template_scorm_proxy_service = templatefile("${path.module}/manifests/proxy-service.yml.tpl", {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
    bucket_uri            = data.aws_s3_bucket.storage.bucket_domain_name
  })

  template_ingress = templatefile("${path.module}/manifests/ingress.yml.tpl", {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
    studio_subdomain      = var.studio_subdomain
  })


  template_ingress_scorm_proxy_service = templatefile("${path.module}/manifests/ingress-scorm-proxy-service.yml.tpl", {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
    studio_subdomain      = var.studio_subdomain
  })

  template_ingress_mfe_config = templatefile("${path.module}/manifests/ingress-mfe-config.yml.tpl", {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
  })

  template_ingress_mfe = templatefile("${path.module}/manifests/ingress-mfe.yml.tpl", {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
  })
}
resource "kubernetes_manifest" "scorm_proxy_service" {
  manifest = yamldecode(local.template_scorm_proxy_service)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(local.template_ingress)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubernetes_manifest" "ingress_scorm_proxy_service" {
  manifest = yamldecode(local.template_ingress_scorm_proxy_service)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
    kubernetes_manifest.ingress_scorm_proxy_service,
  ]
}

resource "kubernetes_manifest" "ingress_mfe_config" {
  manifest = yamldecode(local.template_ingress_mfe_config)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubernetes_manifest" "ingress_mfe" {
  manifest = yamldecode(local.template_ingress_mfe)

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

data "aws_s3_bucket" "storage" {
  bucket = var.s3_bucket_storage
}
