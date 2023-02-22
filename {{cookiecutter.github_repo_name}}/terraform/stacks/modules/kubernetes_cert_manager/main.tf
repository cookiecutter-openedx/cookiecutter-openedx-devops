#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: Add tls certs for EKS cluster load balancer
#        see https://cert-manager.io/docs/
#
# helm reference:
#   brew install helm
#
#   helm repo add jetstack https://charts.jetstack.io
#   helm repo update
#   helm show all jetstack/cert-manager
#   helm show values jetstack/cert-manager
#------------------------------------------------------------------------------
data "aws_route53_zone" "services_subdomain" {
  name = var.services_subdomain
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


module "cert_manager_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "{{ cookiecutter.terraform_aws_modules_iam_assumable_role_with_oidc }}"
  create_role                   = true
  role_name                     = "${var.namespace}-cert_manager-irsa"
  provider_url                  = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.cert_manager_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.cert_manager_namespace}:cert-manager"]
}

data "template_file" "cert-manager-values" {
  template = file("${path.module}/manifests/cert-manager-values.yaml.tpl")
  vars = {
    role_arn                   = module.cert_manager_irsa.iam_role_arn
    namespace                  = var.cert_manager_namespace
    cert_manager_image_version = var.cert_manager_image_version
  }
}

data "template_file" "cert-manager-values" {
  template = file("${path.module}/manifests/cert-manager-values.yaml.tpl")
  vars     = {}
}
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  namespace        = var.cert_manager_namespace
  create_namespace = true

  chart      = "cert-manager"
  repository = "jetstack"
  version    = "{{ cookiecutter.terraform_helm_cert_manager }}"
  values = [
    data.template_file.cert-manager-values.rendered
  ]
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
