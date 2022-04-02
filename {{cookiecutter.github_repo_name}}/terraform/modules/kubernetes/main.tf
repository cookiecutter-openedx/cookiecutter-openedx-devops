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

  eks_managed_node_groups = {
    default = {
      min_size       = var.eks_worker_group_min_size
      max_size       = var.eks_worker_group_max_size
      desired_size   = var.eks_worker_group_desired_size
      instance_types = [var.eks_worker_group_instance_type]
      tags           = var.tags
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
