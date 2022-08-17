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
}

resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.namespace}-eks_worker_group_mgmt"
  description = "openedx_devops: Ingress CLB worker group management"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = var.tags

}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.namespace}-eks_all_worker_management"
  description = "openedx_devops: Ingress CLB worker management"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = var.tags

}


module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "{{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.namespace
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  create_cloudwatch_log_group     = false
  tags = merge(
    var.tags,
    # Tag node group resources for Karpenter auto-discovery
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    { "karpenter.sh/discovery" = var.namespace }
  )

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "openedx_devops: Node to node all ports/protocols"
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
      description                = "openedx_devops: open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_all = {
      description      = "openedx_devops: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    iam_role_additional_policies = [
      "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
  }

  eks_managed_node_groups = {
    # -------------------------------------------------------------------------
    # 1.) Static node group, configured for extended platform idle states.
    # -------------------------------------------------------------------------
    # This group ensures that one node exists in every
    # aws availability zone at all times, which is important for ensuring that
    # there is a matching node for all existing k8s Persistent Volume Claims.
    # The EC2 instance type for this group should be small. the Cookiecutter
    # EC2 default instance type is t3.medium.
    #
    # Cost optimizing the EC2 instance type for this group is a great idea.
    # For example, you might consider purchasing EC2 Reserved instances
    # for these nodes as this will reduce your EC2 costs by around 40%.
    # https://aws.amazon.com/ec2/pricing/reserved-instances/

    k8s_nodes_idle = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      min_size          = var.eks_worker_group_min_size
      max_size          = var.eks_worker_group_max_size
      desired_size      = var.eks_worker_group_desired_size
      instance_types    = [var.eks_worker_group_instance_type]
      tags = merge(
        var.tags,
        { Name = "eks-${var.shared_resource_identifier}-node-idle" }
      )
    }

    # -------------------------------------------------------------------------
    # 2.) Dynamic node group, for scaling.
    # -------------------------------------------------------------------------
    # This node group is managed by Karpenter. There must be at least
    # node in this group at all times in order for Karpenter to monitor
    # load and act on metrics data. Karpenter's bin packing algorithms
    # perform more effectively with larger instance types. The Cookiecutter
    # default instance type is t3.xlarge (4 vCPU / 16 GiB). These instances,
    # beyond the 1 permanent instance, are assumed to be short-lived
    # (a few hours or less) as these are usually only instantiated during
    # bursts of user activity such as at the start of a scheduled lecture or
    # exam on a large mooc.
    karpenter = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.eks_karpenter_group_desired_size
      min_size          = var.eks_karpenter_group_min_size
      max_size          = var.eks_karpenter_group_max_size
      instance_types    = ["${var.eks_karpenter_group_instance_type}"]
      tags = merge(
        var.tags,
        { Name = "eks-${var.shared_resource_identifier}-karpenter" }
      )
    }

  }

}

#------------------------------------------------------------------------------
# Tutor deploys into this namespace, bc of a namesapce command-line argument
# that we pass inside of GitHub Actions deploy workflow
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "namespace-shared" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.eks]
}
