#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------ 
locals {
  name = var.environment_namespace
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  #load_config_file       = false
}

resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.environment_namespace}-eks_worker_group_mgmt"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = var.tags

}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.environment_namespace}-eks_all_worker_management"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = var.tags

}

data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
}


resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "openedx"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_version = "1.21"

  cluster_name    = var.environment_namespace
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id
  enable_irsa     = var.enable_irsa

  self_managed_node_groups = {
    one = {
      name = "remove-me"
      instance_type   = "t2.medium"
      subnet_ids      = var.subnet_ids
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]

      max_size     = 1
      min_size     = 1
      desired_size = 1
    }
  }
  tags = var.tags
}
