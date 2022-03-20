
locals {
  name            = var.environment_namespace
  cluster_version = var.eks_cluster_version
  region          = var.aws_region

  tags = var.tags
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "{{ cookiecutter.terraform_aws_modules_eks }}"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    # mcdaniel mar-2022: moved this to Fargate profile, below.
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    #coredns = {
    #  resolve_conflicts = "OVERWRITE"
    #}
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

  # mcdaniel mar-2022: disabling this. it's no longer necessary because coredns is moved to
  #                    to a Fargate profile, below.
  #
  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  #eks_managed_node_groups = {
  #  managed = {
  #    desired_size = 1
  #
  #    instance_types = ["t3.large"]
  #    labels = {
  #      Managed    = "managed_node_groups"
  #      GithubRepo = "terraform-aws-eks"
  #      GithubOrg  = "terraform-aws-modules"
  #    }
  #    tags = {
  #      ExtraTag = "managed"
  #    }
  #  }
  #}

  fargate_profiles = {
    openedx = {
      name = "openedx"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "openedx_backend"
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

      subnet_ids = var.private_subnet_ids

      tags = {
        Owner = "coredns"
      }
    }
  }

  tags = local.tags
}
