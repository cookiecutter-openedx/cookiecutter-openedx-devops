#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------ 
locals {
  name = var.cluster_name
  tags = var.tags
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
  load_config_file       = false
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
  version         = ">= 17.24.0, < 18.0.0"
  cluster_name    = local.name
  cluster_version = var.cluster_version
  subnets         = var.subnets
  vpc_id          = var.vpc_id
  enable_irsa     = var.enable_irsa
  manage_aws_auth = true

  worker_groups = [
    {
      instance_type                 = var.worker_group_instance_type
      asg_desired_capacity          = var.worker_group_asg_min_size
      asg_min_size                  = var.worker_group_asg_min_size
      asg_max_size                  = var.worker_group_asg_max_size
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
      subnets                       = var.subnets
    }
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts

  tags = var.tags
}
