

resource "kubectl_manifest" "certificate" {
  yaml_body = file("${path.module}/manifests/certificate.yml")

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_route53_record.root_naked,
    aws_iam_policy.cert_manager_policy,
    aws_route53_record.root_wildcard,
  ]
}

data "aws_route53_zone" "admin_domain" {
  name = var.admin_domain
}
data "template_file" "cluster-issuer" {
  template = file("${path.module}/manifests/cluster-issuer.yml.tpl")
  vars = {
    namespace = var.namespace
    aws_region = var.aws_region
    hosted_zone_id = data.aws_route53_zone.admin_domain.id
  }
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = data.template_file.cluster-issuer.rendered

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_route53_record.root_naked,
    aws_iam_policy.cert_manager_policy,
    aws_route53_record.root_wildcard,
  ]
}
