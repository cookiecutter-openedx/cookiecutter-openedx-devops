#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#
# TO DO: remove eks_managed_node_groups
#
# how this works, see: 
# - https://betterprogramming.pub/with-latest-updates-create-amazon-eks-fargate-cluster-and-managed-node-group-using-terraform-bc5cfefd5773
# - https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
#
# Note:
# --------------
# I've added wonky code to this module in order to work around some buggy 
# Terraform behavior related to dependencies that surfaces resource 
# declaraationa like, `resource "aws_iam_role_policy_attachment"`.
# see https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
# in the section about "Error: Invalid for_each argument ..."
#------------------------------------------------------------------------------ 

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
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
      node_group_name = "default"
      node_role_arn   = aws_iam_role.eks_node_group_role.arn
      subnet_ids      = var.private_subnets

      desired_size = 1
      max_size     = 1
      min_size     = 1

      instance_types = ["t3.small"]

      labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      # mcdaniel mar-2022: i had to bail on this. Terraform cannot correctly
      # determinte the dependency chain. you end up with
      # a "Terrform error: Cycle ..." no matter how you approach this.
      # -----------------------------------------------------------------------
      # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
      # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
      #depends_on = [
      #  aws_iam_role_policy_attachment.EKSWorkerNodePolicy,
      #  aws_iam_role_policy_attachment.EKS_CNI_Policy,
      #  aws_iam_role_policy_attachment.EC2_ContainerRegistry_ReadOnly,
      #]

      timeouts = {
        create = "20m"
        delete = "20m"
      }

      tags = var.tags
    }
  }

  # mcdaniel mar-2002: i tried to move this to its own resource
  # declaration using `resource "aws_eks_fargate_profile" "yadda-yadda" {}`
  # but went in circles due to an arcane Terraform compiler bug.
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "backend"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }

    }
  }

  # mcdaniel mar-2022:
  # see https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/fargate_profile
  # Error: Invalid for_each argument ...
  #depends_on = [
  #  aws_iam_role_policy_attachment.EKS_Policy_Cluster,
  #  aws_iam_role_policy_attachment.EKS_VPC_ResourceController_Cluster,
  #  aws_cloudwatch_log_group.eks_cluster
  #]

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

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.environment_namespace}/eks_cluster"
  retention_in_days = 30

  tags = var.tags
}

################################################################################
# IAM Roles and policies that are required in order for Fargate to manage its 
# child resources.
################################################################################

resource "aws_iam_role" "eks_fargate_role" {
  name = "${var.environment_namespace}-fargate_cluster_role"
  description = "Allow fargate cluster to allocate resources for running pods"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment_namespace}-cluster-role"
  description = "Allow cluster to manage node groups, fargate nodes and cloudwatch logs"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "eks-fargate-pods.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.environment_namespace}-node-group_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}



resource "aws_iam_policy" "EKS_CloudWatchMetrics" {
  name   = "EKS_CloudWatchMetrics"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}


################################################################################
# I. EKS Cluster dependencies. Attach the new policies to the new roles
################################################################################

# for the eks module's dependencies: 1 of 2
resource "aws_iam_role_policy_attachment" "EKS_Policy_Cluster" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_Policy_Fargate"
  role       = aws_iam_role.eks_cluster_role.name
}

# for the eks module's dependencies: 2 of 2
resource "aws_iam_role_policy_attachment" "EKS_VPC_ResourceController_Cluster" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_VPC_ResourceController_Fargate"
  role       = aws_iam_role.eks_cluster_role.name
}

# non-dependent attachment, also for the eks module
resource "aws_iam_role_policy_attachment" "EKS_CloudWatchMetrics" {
  policy_arn = aws_iam_policy.EKS_CloudWatchMetrics.arn
  role       = aws_iam_role.eks_cluster_role.name
}

################################################################################
# II. EKS Cluster Fargate Profile dependencies. 
#     Attach the new policies to the new roles
################################################################################


# for the eks module's eks_managed_node_groups' dependencies: 1 of 3
resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/EKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

# for the eks module's eks_managed_node_groups' dependencies: 2 of 3
resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

# for the eks module's eks_managed_node_groups' dependencies: 3 of 3
resource "aws_iam_role_policy_attachment" "EC2_ContainerRegistry_ReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/EC2_ContainerRegistry_ReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# non-dependent attachment, also for the Fargate profile
resource "aws_iam_role_policy_attachment" "EKS_PodExecution_Fargate" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_PodExecution_Fargate"
  role       = aws_iam_role.eks_fargate_role.name
}

# non-dependent attachment, also for the Fargate profile
resource "aws_iam_role_policy_attachment" "EKS_Policy_Fargate" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_Policy_Fargate"
  role       = aws_iam_role.eks_fargate_role.name
}

# non-dependent attachment, also for the Fargate profile
resource "aws_iam_role_policy_attachment" "EKS_VPC_ResourceController_Fargate" {
  policy_arn = "arn:aws:iam::aws:policy/EKS_VPC_ResourceController_Fargate"
  role       = aws_iam_role.eks_fargate_role.name
}
