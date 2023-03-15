#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Karpenter scaling service.
# see: https://karpenter.sh/v0.19.3/getting-started/getting-started-with-terraform/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add karpenter https://charts.karpenter.sh/
#   helm repo update
#   helm search repo karpenter
#   helm show values karpenter/karpenter
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
# FIX NOTE: the policy lacks some permissions for creating/terminating instances
#  as well as pricing:GetProducts.
#
# FIXED. but see note below about version.
#
# see: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
locals {
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes_karpenter"
      "cookiecutter/resource/source"  = "charts.karpenter.sh"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_helm_karpenter }}"
    }
  )
}

data "template_file" "karpenter-values" {
  template = file("${path.module}/yml/karpenter-values.yaml")
}


resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"

  version = "~> {{ cookiecutter.terraform_helm_karpenter }}"

  values = [
    data.template_file.karpenter-values.rendered
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_controller_irsa_role.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = var.stack_namespace
  }

  set {
    name  = "clusterEndpoint"
    value = data.aws_eks_cluster.eks.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

}

#------------------------------------------------------------------------------
#                           SUPPORTING RESOURCES
#------------------------------------------------------------------------------
module "karpenter_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  # mcdaniel aug-2022: specifying an explicit version causes this module to create
  # an incomplete IAM policy.
  #version = "~> 5.3"

  role_name                          = "karpenter-controller-${var.stack_namespace}"
  create_role                        = true
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_id = data.aws_eks_cluster.eks.name
  karpenter_controller_node_iam_role_arns = [
    var.service_node_group_iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      "cookiecutter/resource/version" = "latest"
    }
  )

}


resource "random_pet" "this" {
  length = 2
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.stack_namespace}-${random_pet.this.id}"
  role = var.service_node_group_iam_role_name
}


# see: https://karpenter.sh/v0.6.1/provisioner/
resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
      - key: node.kubernetes.io/instance-type
        operator: In
        values: ["t3.2xlarge", "t3.xlarge", "t2.2xlarge", "t3.large", "t2.xlarge"]
    limits:
      resources:
        cpu: "400"        # 100 * 4 cpu
        memory: 1600Gi    # 100 * 16Gi
    provider:
      subnetSelector:
        karpenter.sh/discovery: ${var.stack_namespace}
      securityGroupSelector:
        karpenter.sh/discovery: ${var.stack_namespace}
      tags:
        karpenter.sh/discovery: ${var.stack_namespace}

    # If nil, the feature is disabled, nodes will never terminate
    ttlSecondsUntilExpired: 600           # 10 minutes = 60 seconds * 10 minutes

    # If nil, the feature is disabled, nodes will never scale down due to low utilization
    ttlSecondsAfterEmpty: 600             # 10 minutes = 60 seconds * 10 minutes
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "aws_iam_role" "ec2_spot_fleet_tagging_role" {
  name = "AmazonEC2SpotFleetTaggingRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "spotfleet.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_iam_role"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2_spot_fleet_tagging" {
  role       = aws_iam_role.ec2_spot_fleet_tagging_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "kubectl_manifest" "vpa-karpenter" {
  yaml_body = file("${path.module}/yml/vpa-karpenter.yaml")

  depends_on = [
    helm_release.karpenter
  ]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}

resource "kubernetes_secret" "cookiecutter" {
  metadata {
    name      = "cookiecutter"
    namespace = var.cert_manager_namespace
  }

  # https://stackoverflow.com/questions/64134699/terraform-map-to-string-value
  data = {
    tags = jsonencode(local.tags)
  }
}
