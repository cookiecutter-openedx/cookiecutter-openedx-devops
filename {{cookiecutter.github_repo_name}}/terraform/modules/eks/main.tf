#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
locals {
  name = var.environment_namespace
}

#data "tls_certificate" "cluster" {
#  url = module.eks.cluster_oidc_issuer_url
#}

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

resource "kubernetes_namespace" "openedx" {
  metadata {
    annotations = {
      name = "openedx"
    }

    labels = {
      mylabel = "openedx"
    }

    name = "openedx"
  }
}


#------------------------------------------------------------------------------
# FIX NOTE. make a decision on whether to use this or not.
#
# cluster_addons = {
#   vpc-cni = {
#     resolve_conflicts        = "OVERWRITE"
#     service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
#   }
# }
#
#------------------------------------------------------------------------------
module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

#------------------------------------------------------------------------------
# Technical documentation:
# - https://docs.aws.amazon.com/eks
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
#
#------------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "{{ cookiecutter.terraform_aws_modules_eks }}"

  cluster_name                    = local.name
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  tags                            = var.tags


  # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      namespace         = "kube-system"
    }
  }


  # see: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/fargate_profile/main.tf
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]
      tags = {
        Owner = "default"
      }
    }
    coredns = {
      name = "coredns"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        }
      ]
    }
  }

}
