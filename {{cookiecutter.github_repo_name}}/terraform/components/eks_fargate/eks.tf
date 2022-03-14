#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
# see: https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile
#------------------------------------------------------------------------------ 

#-----------------------------------------------------------------------------
# references to IAM roles created in the VPC module.
#-----------------------------------------------------------------------------
data "aws_iam_role" "eks_fargate_role" {
  name = "${var.environment_namespace}-fargate_cluster_role"
}

data "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment_namespace}-cluster-role"
}

data "aws_iam_role" "eks_node_group_role" {
  name = "${var.environment_namespace}-node-group_role"
}

data "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name   = "${var.environment_namespace}-EKSClusterCloudWatchMetricsPolicy"
}

data "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

data "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

data "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = data.aws_iam_role.eks_cluster_role.name
}

data "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = data.aws_iam_role.eks_cluster_role.name
}

data "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role       = data.aws_iam_role.eks_cluster_role.name
}

data "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = data.aws_iam_role.eks_node_group_role.name
}





module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          =  var.vpc_id
  subnet_ids                      = var.private_subnets

  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]


  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = {
    example = {
      desired_size = 1

      instance_types = [var.eks_node_group_instance_type]
      labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      depends_on = [
        data.aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        data.aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        data.aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
      ]
      tags = var.tags
    }
  }

  fargate_profiles = {
    default = resource.aws_eks_fargate_profile.default    
  }

  depends_on = [
    data.aws_iam_role_policy_attachment.AmazonEKSClusterPolicy1,
    data.aws_iam_role_policy_attachment.AmazonEKSVPCResourceController1,
    data.aws_cloudwatch_log_group.cloudwatch_log_group
  ]

  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/eks/${var.environment_namespace}/cluster"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_eks_fargate_profile" "default" {
  cluster_name           = var.environment_namespace
  fargate_profile_name   = "default"
  pod_execution_role_arn = data.aws_iam_role.eks_fargate_role.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = var.environment_namespace
  }

  timeouts {
    create = "20m"
    delete = "20m"
  }

  tags = var.tags

}
