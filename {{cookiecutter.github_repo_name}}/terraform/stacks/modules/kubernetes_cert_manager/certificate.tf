data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
}

data "template_file" "certificate" {
  template = file("${path.module}/manifests/certificate.yml.tpl")
  vars = {
    services_subdomain = var.services_subdomain
    namespace          = var.namespace
  }
}

resource "kubectl_manifest" "certificate" {
  yaml_body = data.template_file.certificate.rendered

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_iam_policy.cert_manager_policy,
  ]
}
