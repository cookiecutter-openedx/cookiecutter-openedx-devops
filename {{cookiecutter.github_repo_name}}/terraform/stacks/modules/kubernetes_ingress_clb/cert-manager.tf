#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add tls certs for EKS cluster load balancer
#        see https://cert-manager.io/docs/
#------------------------------------------------------------------------------
module "cert_manager_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.9"
  create_role                   = true
  role_name                     = "${var.namespace}-cert_manager-irsa"
  provider_url                  = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.environment_namespace}:cert-manager"]
}

data "template_file" "cert-manager-values" {
  template = file("${path.module}/cert-manager-values.yaml.tpl")
  vars = {
    role_arn              = module.cert_manager_irsa.iam_role_arn
    environment_namespace = var.environment_namespace
  }
}

#-----------------------------------------------------------
# NOTE: you must initialize a local helm repo in order to run
# this script.
#
#   brew install helm
#   helm repo add cert-manager https://charts.jetstack.io/
#   helm repo update
#
#-----------------------------------------------------------
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = var.environment_namespace
  create_namespace = false

  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "1.9"
  values = [
    data.template_file.cert-manager-values.rendered
  ]
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${var.namespace}-cert-manager-policy"
  path        = "/"
  description = "openedx_devops: Policy, which allows CertManager to create Route53 records"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/*"
      },
      {
        "Effect" : "Allow",
        "Action" : "route53:ListHostedZonesByName",
        "Resource" : "*"
      }
    ]
  })
}
