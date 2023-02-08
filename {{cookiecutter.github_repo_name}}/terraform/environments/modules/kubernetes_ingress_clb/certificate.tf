
data "template_file" "certificate" {
  template = file("${path.module}/manifests/certificate.yml.tpl")
  vars = {
    environment_domain = var.environment_domain
  }
}

data "template_file" "cluster-issuer" {
  template = file("${path.module}/manifests/cluster-issuer.yml.tpl")
  vars = {
    root_domain        = var.root_domain
    environment_domain = var.environment_domain
    namespace          = var.environment_namespace
    aws_region         = var.aws_region
    hosted_zone_id     = data.aws_route53_zone.environment_domain.id
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = data.template_file.cluster-issuer.rendered

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}

resource "kubectl_manifest" "certificate" {
  yaml_body = data.template_file.certificate.rendered

  depends_on = [
    aws_route53_record.naked,
    aws_route53_record.wildcard,
  ]
}
