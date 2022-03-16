#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage:  Amazon Certificate Manager (ACM)
#         Add tls certs for EKS cluster load balancer
#------------------------------------------------------------------------------ 
module "cert_manager_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.1"
  create_role                   = true
  role_name                     = "${var.environment_namespace}-cert_manager-irsa"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.4.0"
  values = [
    templatefile("${path.module}/acm-values.yaml.tpl", {role_arn = module.cert_manager_irsa.iam_role_arn})
  ]
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${var.environment_namespace}-cert-manager-policy"
  path        = "/"
  description = "Policy, which allows CertManager to create Route53 records"
  policy = file("./iam/iam_policy_cert_manager.json")
}