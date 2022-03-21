#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
locals {
  name   = var.environment_namespace
  region = var.aws_region

  tags = var.tags
}

data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
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
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "openedx"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "{{ cookiecutter.terraform_aws_modules_eks }}"

  cluster_name                    = local.name
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = var.enable_irsa


  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
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

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = {
    managed = {
      max_size     = var.eks_worker_group_max_size
      min_size     = var.eks_worker_group_min_size
      desired_size = var.eks_worker_group_desired_size

      instance_types = [var.eks_worker_group_instance_type]
      labels = {
        Managed    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      tags = {
        ExtraTag = "managed"
      }
    }
  }

  fargate_profiles = {
    openedx = {
      name = "openedx"
      selectors = [
        {
          namespace = "workers"
          labels = {
            Application = "openedx_workers"
          }
        },
        {
          namespace = "openedx"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "openedx"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = local.tags
}
