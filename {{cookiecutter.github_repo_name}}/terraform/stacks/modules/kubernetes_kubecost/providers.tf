#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: all providers for Kubernetes and its sub-systems. The general strategy
#        is to manage authentications via aws cli where possible, simply to limit
#        the environment requirements in order to get this module to work.
#
#        another alternative for each of the providers would be to rely on
#        the local kubeconfig file.
#------------------------------------------------------------------------------

data "aws_elb_hosted_zone_id" "main" {}

# Required by Karpenter
data "aws_partition" "current" {}

data "aws_eks_cluster" "eks" {
  name = var.stack_namespace
}

data "aws_eks_cluster_auth" "eks" {
  name = var.stack_namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
