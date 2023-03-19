data "template_file" "ingress" {
  template = file("${path.module}/manifests/ingress.yml.tpl")
  vars = {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
    studio_subdomain      = var.studio_subdomain
  }
}

data "template_file" "ingress_mfe" {
  template = file("${path.module}/manifests/ingress-mfe-config.yml.tpl")
  vars = {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
  }
}

resource "kubectl_manifest" "ingress" {
  yaml_body = data.template_file.ingress.rendered

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubectl_manifest" "ingress_mfe" {
  yaml_body = data.template_file.ingress_mfe.rendered

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

data "aws_s3_bucket" "storage" {
  bucket = var.s3_bucket_storage
}

data "template_file" "proxy_service" {
  template = file("${path.module}/manifests/proxy-service.yml.tpl")
  vars = {
    environment_domain    = var.environment_domain
    environment_namespace = var.environment_namespace
    bucket_uri            = data.aws_s3_bucket.storage.bucket_domain_name
  }
}
resource "kubectl_manifest" "proxy_service" {
  yaml_body = data.template_file.proxy_service.rendered

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}
