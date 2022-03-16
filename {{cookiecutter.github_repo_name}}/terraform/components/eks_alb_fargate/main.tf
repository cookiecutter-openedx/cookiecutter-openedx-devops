#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: build an EKS cluster with a Fargate Compute Cluster and
#        a public-facing Application Load Balancer (ALB)
#------------------------------------------------------------------------------


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name                    = var.environment_namespace
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true

  # FIX NOTE: FIND OUT WHAT THIS MEANS.
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  subnet_ids  = var.subnet_ids
  vpc_id      = var.vpc_id
  enable_irsa = var.enable_irsa

  self_managed_node_groups = {
    one = {
      name                          = "remove-me"
      subnet_ids                    = var.subnet_ids
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
      instance_type                 = "t2.medium"
      max_size                      = 1
      min_size                      = 1
      desired_size                  = 1
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = var.tags
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
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
