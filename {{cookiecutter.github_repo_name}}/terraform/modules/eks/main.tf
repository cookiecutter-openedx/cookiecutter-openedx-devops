#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster with one managed node group for EC2
#        plus a Fargate profile for serverless computing.
#
# Technical documentation:
# - https://docs.aws.amazon.com/eks
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
# - https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html
#
#------------------------------------------------------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "{{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  tags                            = var.tags

  # mcdaniel mar-2022: pushing create to 30 minutes because of the coredns add-on,
  # which takes around 25 minutes.
  cluster_timeouts = {
    create = "30m"
    update = "20m"
    delete = "20m"
  }

  #----------------------------------------------------------------------------
  # cluster_addons
  #
  # AWS Load Balancer Controller add-on
  #   Moved to its own module in this repo: ../eks_ingress_alb_controller
  #   https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
  #
  # coredns:
  #   CoreDNS is a flexible, extensible DNS server that can serve as the
  #   Kubernetes cluster DNS. When you launch an Amazon EKS cluster with
  #   at least one node, two replicas of the CoreDNS image are deployed by
  #   default, regardless of the number of nodes deployed in your cluster.
  #   The CoreDNS pods provide name resolution for all pods in the cluster.
  #   The CoreDNS pods can be deployed to Fargate nodes if your cluster
  #   includes an AWS Fargate profile with a namespace that matches the
  #   namespace for the CoreDNS Deployment.
  #
  #   https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
  #
  # vpc-cni:
  #   Amazon EKS supports native VPC networking with the Amazon VPC Container
  #   Network Interface (CNI) plugin for Kubernetes. Using this plugin allows
  #   Kubernetes pods to have the same IP address inside the pod as they do on
  #   the VPC network. For more information, see Pod networking (CNI).
  #   https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html
  #
  # kube-proxy:
  #   Kube-proxy maintains network rules on each Amazon EC2 node. It enables network
  #   communication to your pods. Kube-proxy is not deployed to Fargate nodes."
  #   https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  #
  #----------------------------------------------------------------------------
  cluster_addons = {
    coredns = {
      resolve_conflicts        = "OVERWRITE"
      tags                     = var.tags
      service_account_role_arn = aws_iam_role.fargate_pod_execution_role.arn
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      tags                     = var.tags
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  #----------------------------------------------------------------------------
  # node_security_group_additional_rules
  #
  # mcdaniel mar-2022: had to add these in order to overcome network related
  # deployment problems with fargate nodes whereby low-level services like the
  # webhooks for the ALB ingress controller could not communicate with the
  # Fargate nodes.
  #
  # Error: Failed to create Ingress 'ingress-alb-controller/nginx-lb' because: Internal error occurred:
  #        failed calling webhook "vingress.elbv2.k8s.aws":
  #        Post "https://aws-load-balancer-webhook-service.ingress-alb-controller.svc:443/validate-networking-v1-ingress?timeout=10s": context deadline exceeded
  #
  #----------------------------------------------------------------------------
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # see: https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
  fargate_profiles = {
    coredns = {
      name       = "coredns"
      subnet_ids = var.private_subnet_ids

      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "kube-system"
        }

      ]
      tags = var.tags
      # this is redundant, since aws_iam_role.this sets its assume_role_policy
      # to point to this exact fargate profile.
      pod_execution_role = aws_iam_role.fargate_pod_execution_role
    }

    fargate-node = {
      name = "application"
      selectors = [
        {
          namespace = "application"
        },
        {
          namespace = "openedx"
        },
        {
          namespace = "default"
        }
      ]
      tags = var.tags
      # this is redundant, since aws_iam_role.this sets its assume_role_policy
      # to point to this exact fargate profile.
      pod_execution_role = aws_iam_role.fargate_pod_execution_role
    }
  }

}

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

resource "kubernetes_namespace" "application" {
  metadata {
    name = "application"
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "openedx" {
  metadata {
    name = "openedx"
  }
  depends_on = [module.eks]
}

#------------------------------------------------------------------------------
#
# Before you create a Fargate profile, you must create an IAM role with the
# AmazonEKSFargatePodExecutionRolePolicy.
# This policy exactly: https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/policies/arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy$jsonEditor
#
# Create the Amazon EKS Fargate pod execution role.
#
# see:
# - https://docs.aws.amazon.com/eks/latest/userguide/pod-execution-role.html#create-pod-execution-role
#------------------------------------------------------------------------------

resource "aws_iam_role" "fargate_pod_execution_role" {
  name        = "${var.environment_namespace}-EKSFargatePodExecutionRole"
  description = "AWS Fargate pod execution role"

  tags                  = var.tags
  force_detach_policies = true
  managed_policy_arns   = ["arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:eks:{{ cookiecutter.global_aws_region }}:{{ cookiecutter.global_account_id }}:fargateprofile/${var.environment_namespace}/*",
            "aws:SourceArn" : "arn:aws:eks:{{ cookiecutter.global_aws_region }}:{{ cookiecutter.global_account_id }}:addon/${var.environment_namespace}/*"
          }
        },
        "Principal" : {
          "Service" : "eks-fargate-pods.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
