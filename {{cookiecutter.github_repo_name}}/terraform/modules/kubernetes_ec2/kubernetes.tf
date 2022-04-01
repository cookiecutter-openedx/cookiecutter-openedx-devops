#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: declare a kubernetes provider so that terraform
#        can communicate with the kubernetes api.
#------------------------------------------------------------------------------
data "aws_eks_cluster" "cluster" {
  name       = var.environment_namespace
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.environment_namespace
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
