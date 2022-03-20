#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Create EKS
#------------------------------------------------------------------------------

data "aws_vpc" "selected" {
  id = var.vpc_id
}

module "eks" {
  source              = "./terraform-aws-eks"
  name                = var.environment_namespace
  tags                = var.tags
  subnets             = var.private_subnet_ids
  kubernetes_version  = var.eks_cluster_version
  managed_node_groups = []
  fargate_profiles    = []
  node_groups = [
    {
      name          = "default"
      min_size      = var.eks_worker_group_min_size
      max_size      = var.eks_worker_group_max_size
      desired_size  = var.eks_worker_group_desired_size
      instance_type = var.eks_worker_group_instance_type
    }
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "lb-controller" {
  source       = "Young-ook/eks/aws//modules/lb-controller"
  enabled      = module.eks.features.managed_node_groups_enabled || module.eks.features.node_groups_enabled
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = var.tags
}
