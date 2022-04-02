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
# - https://docs.aws.amazon.com/kubernetes/latest/userguide/fargate-profile.html
#
#------------------------------------------------------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "{{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  tags                            = var.tags

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      tags              = var.tags
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      tags              = var.tags
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size       = var.eks_worker_group_min_size
      max_size       = var.eks_worker_group_max_size
      desired_size   = var.eks_worker_group_desired_size
      instance_types = [var.eks_worker_group_instance_type]
      labels = {
        Environment = var.environment_namespace
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      tags = var.tags
    }
  }

}

#------------------------------------------------------------------------------
# Tutor deploys into this namespace, bc of a namesapce command-line argument
# that we pass inside of GitHub Actions deploy workflow
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "openedx" {
  metadata {
    name = "openedx"
  }
  depends_on = [module.eks]
}


#------------------------------------------------------------------------------
# This security group is created automatically by the EKS and is one of three
# security groups associated with the cluster. The terraform module
# terraform-aws-modules/eks/aws, above, provides hooks for the other two, but
# does not provide us with a way to modify this one.
#
# We have to rely on the kubernetes-managed resource tags to identify it.
#
# Also, note that this security group is identifiable in the AWS Console
# with the following description: "EKS created security group applied to ENI that
#     is attached to EKS Control Plane master nodes, as well as any managed
#     workloads."
#------------------------------------------------------------------------------
data "aws_security_group" "eks" {
  tags = merge(
    {
      "kubernetes.io/cluster/${var.environment_namespace}" = "owned"
    },
    {
      "aws:eks:cluster-name" = "${var.environment_namespace}"
    },
  )

  depends_on = [module.eks]
}

# we need this so that we can pass the cidr of the vpc
# to the security group rule below.
data "aws_vpc" "environment" {

  filter {
    name   = "tag-value"
    values = ["${var.environment_namespace}"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }

}

#------------------------------------------------------------------------------
# mcdaniel mar-2022
# this is needed so that Fargate nodes can receive traffic from resources
# inside the VPC; namely, the ALB.
#------------------------------------------------------------------------------
resource "aws_security_group_rule" "nginx" {
  description       = "http port 80 from inside the VPC"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.environment.cidr_block]
  security_group_id = data.aws_security_group.eks.id
  depends_on        = [module.eks]
}
