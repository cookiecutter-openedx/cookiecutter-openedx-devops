#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

#data "tls_certificate" "cluster" {
#  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
#}

data "aws_eks_cluster" "eks" {
  name = var.namespace
}

data "aws_eks_cluster" "cluster" {
  name = var.namespace
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
