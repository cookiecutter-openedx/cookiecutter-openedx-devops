#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: installs Karpenter scaling service.
# see: https://karpenter.sh/v0.13.2/getting-started/getting-started-with-terraform/
#
# requirements: you must initialize a local helm repo in order to run
# this mdoule.
#
#   brew install helm
#   helm repo add karpenter https://charts.karpenter.sh/
#   helm repo update
#   helm search repo karpenter
#
# NOTE: run `helm repo update` prior to running this
#       Terraform module.
#-----------------------------------------------------------
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.13.2"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_controller_irsa_role.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  depends_on = [
    module.eks,
    module.karpenter_controller_irsa_role,
    aws_iam_instance_profile.karpenter,
    aws_iam_role.ec2_spot_fleet_tagging_role,
    aws_iam_role_policy_attachment.ec2_spot_fleet_tagging,
  ]
}

# FIX NOTE: the policy lacks some permissions for creating/terminating instances
#  as well as pricing:GetProducts.
#
# FIXED. but see note below about version.
#
# see: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
module "karpenter_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  # mcdaniel aug-2022: specifying an explicit version causes this module to create
  # an incomplete IAM policy.
  #version = "~> 5.3"

  role_name                          = "karpenter-controller-${var.namespace}"
  create_role                        = true
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_id = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["karpenter"].iam_role_arn,
    module.eks.eks_managed_node_groups["k8s_nodes_idle"].iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = var.tags

}

resource "random_pet" "this" {
  length = 2
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.namespace}-${random_pet.this.id}"
  role = module.eks.eks_managed_node_groups["karpenter"].iam_role_name
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
        karpenter.sh/discovery: ${var.namespace}
      securityGroupSelector:
        karpenter.sh/discovery: ${var.namespace}
      tags:
        karpenter.sh/discovery: ${var.namespace}

    # If nil, the feature is disabled, nodes will never terminate
    ttlSecondsUntilExpired: 600           # 10 minutes = 60 seconds * 10 minutes

    # If nil, the feature is disabled, nodes will never scale down due to low utilization
    ttlSecondsAfterEmpty: 600             # 10 minutes = 60 seconds * 10 minutes
  YAML

  depends_on = [
    module.eks,
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

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ec2_spot_fleet_tagging" {
  role       = aws_iam_role.ec2_spot_fleet_tagging_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

resource "kubectl_manifest" "vpa-karpenter" {
  yaml_body = file("${path.module}/yml/verticalpodautoscalers/vpa-karpenter.yaml")

  depends_on = [
    module.eks,
    helm_release.vpa,
    helm_release.karpenter
  ]
}
