

resource "kubectl_manifest" "certificate" {
  yaml_body = file("${path.module}/manifests/certificate.yml")

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_route53_record.naked,
    aws_iam_policy.cert_manager_policy,
    aws_route53_record.wildcard,
  ]
}

resource "kubectl_manifest" "cluster-issuer" {
  yaml_body = file("${path.module}/manifests/cluster-issuer.yml")

  depends_on = [
    module.cert_manager_irsa,
    helm_release.cert-manager,
    aws_route53_record.naked,
    aws_iam_policy.cert_manager_policy,
    aws_route53_record.wildcard,
  ]
}
