data "template_file" "cluster-issuer" {
  template = file("${path.module}/manifests/cluster-issuer.yml.tpl")
  vars = {
    root_domain        = var.root_domain
    services_subdomain = var.services_subdomain
    namespace          = var.namespace
    aws_region         = var.aws_region
    hosted_zone_id     = data.aws_route53_zone.services_subdomain.id
  }
}



resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = data.template_file.cluster-issuer.rendered

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_iam_policy.cert_manager_policy,
  ]
}
