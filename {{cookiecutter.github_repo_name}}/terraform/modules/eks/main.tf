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
# - https://docs.aws.amazon.com/eks
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
# - https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html
#
#------------------------------------------------------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "{{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  tags                            = var.tags

  # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
  cluster_addons = {
    coredns = {
      resolve_conflicts        = "OVERWRITE"
      tags                     = var.tags
      service_account_role_arn = aws_iam_role.fargate_pod_execution_role.arn
    }
    kube-proxy = {
      tags                     = var.tags
      service_account_role_arn = aws_iam_role.fargate_pod_execution_role.arn
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      tags                     = var.tags
      service_account_role_arn = aws_iam_role.fargate_pod_execution_role.arn
    }
  }

  # FIX NOTE:
  # regarding https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/2462
  # this is allowing all traffic -- the group is wide open.

  # Resolution for
  # Error: Failed to create Ingress 'ingress-alb-controller/nginx-lb' because: Internal error occurred:
  #        failed calling webhook "vingress.elbv2.k8s.aws":
  #        Post "https://aws-load-balancer-webhook-service.ingress-alb-controller.svc:443/validate-networking-v1-ingress?timeout=10s": context deadline exceeded
  #
  # private subnet cidr is 192.168.0.0/16 ?
  node_security_group_additional_rules = {
    inter_node = {
      description = "Allow traffic between nodes and control plane"
      protocol    = "-1"
      from_port   = 9443 // doesn't appear to do anything
      to_port     = 9443
      type        = "ingress" // needs to be tightened
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  #eks_managed_node_groups = {
  #  default = {
  #    min_size       = var.eks_worker_group_min_size
  #    max_size       = var.eks_worker_group_max_size
  #    desired_size   = var.eks_worker_group_desired_size
  #    instance_types = [var.eks_worker_group_instance_type]
  #    labels = {
  #      Environment = var.environment_namespace
  #      GithubRepo  = "terraform-aws-eks"
  #      GithubOrg   = "terraform-aws-modules"
  #    }
  #    tags = var.tags
  #    timeouts = {
  #      create = "10m"
  #      delete = "10m"
  #    }
  #  }
  #}

  fargate_profiles = {
    coredns = {
      name       = "coredns"
      subnet_ids = var.private_subnet_ids

      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]
      tags = var.tags
      # this is redundant, since aws_iam_role.this sets its assume_role_policy
      # to point to this exact fargate profile.
      pod_execution_role = aws_iam_role.fargate_pod_execution_role
    }

    fargate-node = {
      name = "fargate-node"
      selectors = [
        {
          namespace = "fargate-node"
        },
        {
          namespace = "default"
        }
      ]
      tags = var.tags
      timeouts = {
        create = "10m"
        delete = "10m"
      }
      # this is redundant, since aws_iam_role.this sets its assume_role_policy
      # to point to this exact fargate profile.
      pod_execution_role = aws_iam_role.fargate_pod_execution_role
    }
  }

}

#------------------------------------------------------------------------------
#
# Before you create a Fargate profile, you must create an IAM role with the
# AmazonEKSFargatePodExecutionRolePolicy.
# This policy exactly: https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/policies/arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy$jsonEditor
#
# Create the Amazon EKS Fargate pod execution role.
#
# see:
# - https://docs.aws.amazon.com/eks/latest/userguide/pod-execution-role.html#create-pod-execution-role
#------------------------------------------------------------------------------

resource "aws_iam_role" "fargate_pod_execution_role" {
  name        = "${var.environment_namespace}-EKSFargatePodExecutionRole"
  description = "AWS Fargate pod execution role"

  tags                  = var.tags
  force_detach_policies = true
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:eks:{{ cookiecutter.global_aws_region }}:{{ cookiecutter.global_account_id }}:fargateprofile/${var.environment_namespace}/*",
            "aws:SourceArn" : "arn:aws:eks:{{ cookiecutter.global_aws_region }}:{{ cookiecutter.global_account_id }}:addon/${var.environment_namespace}/*"
          }
        },
        "Principal" : {
          "Service" : "eks-fargate-pods.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
