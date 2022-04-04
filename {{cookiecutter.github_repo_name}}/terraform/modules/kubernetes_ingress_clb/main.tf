#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

data "aws_eks_cluster" "eks" {
  name = var.environment_namespace
}

data "aws_eks_cluster" "cluster" {
  name = var.environment_namespace
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.environment_namespace
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.environment_namespace}-eks_worker_group_mgmt"
  description = "openedx_devops: Ingress CLB worker group management"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = var.tags

}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.environment_namespace}-eks_all_worker_management"
  description = "openedx_devops: Ingress CLB worker management"
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = var.tags

}

data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
