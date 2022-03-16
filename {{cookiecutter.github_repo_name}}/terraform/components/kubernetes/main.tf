#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an EKS cluster.
#------------------------------------------------------------------------------
data "aws_eks_cluster" "eks" {
  name = var.environment_namespace
}

data "aws_eks_cluster_auth" "eks" {
  name = var.environment_namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.environment_namespace
  }
}
