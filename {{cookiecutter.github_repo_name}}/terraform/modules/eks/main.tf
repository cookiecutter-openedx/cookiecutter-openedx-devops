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
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
  }

  fargate_profiles = {
    fargate-node = {
      name = "fargate-node"
      selectors = [
        {
          namespace = "fargate-node"
        }
      ]
      tags = var.tags
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    },
    kube-system = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]
      tags = var.tags
      timeouts = {
        create = "10m"
        delete = "10m"
      }
    }
  }

}
