#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage:  kubernetes configuration
#------------------------------------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = resource.aws_eks_cluster.eks.arn
}

data "aws_eks_cluster_auth" "eks" {
  name = resource.aws_eks_cluster.eks.arn
}

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
