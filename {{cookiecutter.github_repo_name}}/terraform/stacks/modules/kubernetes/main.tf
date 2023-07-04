#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster with one managed node group for EC2
#        plus a Fargate profile for serverless computing.
#
# Technical documentation:
# - https://docs.aws.amazon.com/kubernetes
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
#
#------------------------------------------------------------------------------

locals {
  # Used by Karpenter config to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/kubernetes"
    }
  )

}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> {{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.namespace
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  create_cloudwatch_log_group     = false
  enable_irsa                     = true

  # NOTE:
  # larger organizations might want to change these two settings
  # in order to further restrict which IAM users have access to
  # the AWS EKS Kubernetes Secrets. Note that at cluster creation,
  # this key is benign since Kubernetes secrets encryption
  # is not enabled by default.
  #
  # AWS EKS KMS console: https://us-east-2.console.aws.amazon.com/kms/home
  #
  # audit your AWS EKS KMS key access by running:
  # aws kms get-key-policy --key-id ADD-YOUR-KEY-ID-HERE --region us-east-2 --policy-name default --output text
  create_kms_key = var.eks_create_kms_key
  kms_key_owners = var.kms_key_owners

  # add the bastion IAM user to aws-auth.mapUsers so that
  # kubectl and k9s work from inside the bastion server by default.
  manage_aws_auth_configmap = true
  aws_auth_users = var.map_users

  tags = merge(
    local.tags,
    # Tag node group resources for Karpenter auto-discovery
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    { "karpenter.sh/discovery" = var.namespace },
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/eks/aws"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_eks }}"
    }
  )

  cluster_addons = {
    vpc-cni = {
      addon_version = "v1.13.0-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.10.1-eksbuild.1"
    }
    kube-proxy = {
      addon_version = "v1.27.1-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
      addon_version            = "v1.19.0-eksbuild.2"
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "cookiecutter: Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [
        "172.16.0.0/12",
        "192.168.0.0/16",
      ]
    }
    port_8443 = {
      description                = "cookiecutter: open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_all = {
      description      = "cookiecutter: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    # This node group is managed by Karpenter. There must be at least
    # node in this group at all times in order for Karpenter to monitor
    # load and act on metrics data. Karpenter's bin packing algorithms
    # perform more effectively with larger instance types. The Cookiecutter
    # default instance type is t3.xlarge (4 vCPU / 16 GiB). These instances,
    # beyond the 1 permanent instance, are assumed to be short-lived
    # (a few hours or less) as these are usually only instantiated during
    # bursts of user activity such as at the start of a scheduled lecture or
    # exam on a large mooc.
    {{ cookiecutter.global_platform_shared_resource_identifier }} = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.eks_service_group_desired_size
      min_size          = var.eks_service_group_min_size
      max_size          = var.eks_service_group_max_size

      labels = {
        node-group = "{{ cookiecutter.global_platform_shared_resource_identifier }}"
      }

      iam_role_additional_policies = {
        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }

      instance_types = ["${var.eks_service_group_instance_type}"]
      tags = merge(
        local.tags,
        module.cookiecutter_meta.tags,
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { Name = "eks-${var.shared_resource_identifier}-{{ cookiecutter.global_platform_shared_resource_identifier }}" },
        {
          "cookiecutter/resource/source"  = "terraform-aws-modules/eks/aws"
          "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_eks }}"
        }
      )
    }

    hosting = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.eks_hosting_group_desired_size
      min_size          = var.eks_hosting_group_min_size
      max_size          = var.eks_hosting_group_max_size

      labels = {
        node-group = "{{ cookiecutter.global_platform_shared_resource_identifier }}"
      }

      iam_role_additional_policies = {
        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }

      instance_types = ["${var.eks_hosting_group_instance_type}"]
      tags = merge(
        local.tags,
        module.cookiecutter_meta.tags,
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { Name = "eks-${var.shared_resource_identifier}-hosting" },
        {
          "cookiecutter/resource/source"  = "terraform-aws-modules/eks/aws"
          "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_eks }}"
        }
      )
    }

  }
}

#==============================================================================
#                             SUPPORTING RESOURCES
#==============================================================================

resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.namespace}-eks_hosting_group_mgmt"
  description = "cookiecutter: Ingress CLB worker group management"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = merge(
    local.tags,
    { Name = "eks-${var.shared_resource_identifier}-worker_group_mgmt" },
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.namespace}-eks_all_worker_management"
  description = "cookiecutter: Ingress CLB worker management"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = merge(
    local.tags,
    { Name = "eks-${var.shared_resource_identifier}-all_worker_mgmt" },
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  )
}



resource "kubernetes_namespace" "namespace-shared" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.eks]
}

{% if cookiecutter.wordpress_add_site|upper == "Y" -%}
resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = "wordpress"
  }
  depends_on = [module.eks]
}{% endif -%}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
