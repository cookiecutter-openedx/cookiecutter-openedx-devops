#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add tls certs for EKS cluster load balancer
#------------------------------------------------------------------------------
module "cert_manager_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 4.1"
  create_role                   = true
  role_name                     = "${var.environment_namespace}-cert_manager-irsa"
  provider_url                  = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}

data "template_file" "cert-manager-values" {
  template = file("${path.module}/cert-manager-values.yaml.tpl")
  vars = {
    role_arn = module.cert_manager_irsa.iam_role_arn
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.4.0"
  values = [data.template_file.cert-manager-values.rendered
  ]
}

resource "aws_iam_policy" "cert_manager_policy" {
  name        = "${var.environment_namespace}-cert-manager-policy"
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
