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
# - https://docs.aws.amazon.com/kubernetes
# - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/
# - https://docs.aws.amazon.com/kubernetes/latest/userguide/fargate-profile.html
#
#------------------------------------------------------------------------------
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "{{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.environment_namespace
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                     = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  tags                            = var.tags

  # mcdaniel mar-2022: pushing create to 30 minutes because of the coredns add-on,
  # which takes around 25 minutes.
  cluster_timeouts = {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  #----------------------------------------------------------------------------
  # cluster_addons
  #
  # AWS Load Balancer Controller add-on
  #   Moved to its own module in this repo: ../kubernetes_ingress_alb_controller
  #   https://docs.aws.amazon.com/kubernetes/latest/userguide/aws-load-balancer-controller.html
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
  #   https://docs.aws.amazon.com/kubernetes/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
  #
  # vpc-cni:
  #   Amazon EKS supports native VPC networking with the Amazon VPC Container
  #   Network Interface (CNI) plugin for Kubernetes. Using this plugin allows
  #   Kubernetes pods to have the same IP address inside the pod as they do on
  #   the VPC network. For more information, see Pod networking (CNI).
  #   https://docs.aws.amazon.com/kubernetes/latest/userguide/pod-networking.html
  #
  # kube-proxy:
  #   Kube-proxy maintains network rules on each Amazon EC2 node. It enables network
  #   communication to your pods. Kube-proxy is not deployed to Fargate nodes."
  #   https://docs.aws.amazon.com/kubernetes/latest/userguide/managing-kube-proxy.html
  #
  # aws-ebs-csi-driver:
  #   we need this if we want to run caddy and elasticsearch on Fargate.
  #   see: https://dev.to/aws-builders/install-manage-amazon-eks-add-ons-with-terraform-2dea
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
    #aws-ebs-csi-driver = {
    #  resolve_conflicts        = "OVERWRITE"
    #  tags                     = var.tags
    #  service_account_role_arn = aws_iam_role.fargate_pod_execution_role.arn
    #}
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

  eks_managed_node_groups = {
    default = {
      min_size       = var.eks_worker_group_min_size
      max_size       = var.eks_worker_group_max_size
      desired_size   = var.eks_worker_group_desired_size
      instance_types = [var.eks_worker_group_instance_type]
      labels = {
        Environment = var.environment_namespace
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      tags = var.tags
    }
  }

  fargate_profiles = {
    fargate = {
      name = "fargate"
      selectors = [
        {
          namespace = "fargate"
        }
      ]
      tags = var.tags
      # this is redundant, since aws_iam_role.this sets its assume_role_policy
      # to point to this exact fargate profile.
      pod_execution_role = aws_iam_role.fargate_pod_execution_role
    }
  }

}

#------------------------------------------------------------------------------
# This security group is created automatically by the EKS and is one of three
# security groups associated with the cluster. The terraform module
# terraform-aws-modules/eks/aws, above, provides hooks for the other two, but
# does not provide us with a way to modify this one.
#
# We have to rely on the kubernetes-managed resource tags to identify it.
#
# Also, note that this security group is identifiable in the AWS Console
# with the following description: "EKS created security group applied to ENI that
#     is attached to EKS Control Plane master nodes, as well as any managed
#     workloads."
#------------------------------------------------------------------------------
data "aws_security_group" "eks" {
  tags = merge(
    {
      "kubernetes.io/cluster/${var.environment_namespace}" = "owned"
    },
    {
      "aws:eks:cluster-name" = "${var.environment_namespace}"
    },
  )

  depends_on = [module.eks]
}

# we need this so that we can pass the cidr of the vpc
# to the security group rule below.
data "aws_vpc" "environment" {

  filter {
    name   = "tag-value"
    values = ["${var.environment_namespace}"]
  }
  filter {
    name   = "tag-key"
    values = ["Name"]
  }

}

#------------------------------------------------------------------------------
# mcdaniel mar-2022
# this is needed so that Fargate nodes can receive traffic from resources
# inside the VPC; namely, the ALB.
#------------------------------------------------------------------------------
resource "aws_security_group_rule" "nginx" {
  description       = "http port 80 from inside the VPC"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.environment.cidr_block]
  security_group_id = data.aws_security_group.eks.id
  depends_on        = [module.eks]
}

#------------------------------------------------------------------------------
# mcdaniel mar-2022
# i copied this from an example in the terraform documentation. it's referenced
# by the vpc-cni add_on service_account_role_arn, but i'm not 100%
# certain that it's really necessary to provide our own custom-made iam role.
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
# The Github Actions deployment workflow deploys all of the Tutor docker
# containers into this "openedx" namespace.
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "openedx" {
  metadata {
    name = "openedx"
  }
  depends_on = [module.eks]
}


#------------------------------------------------------------------------------
# mcdaniel mar-2022: before you create a Fargate profile, you must create an IAM
# role with the AmazonEKSFargatePodExecutionRolePolicy.
#
# This is the policy: https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/policies/arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy$jsonEditor
#
# see:
# - https://docs.aws.amazon.com/kubernetes/latest/userguide/pod-execution-role.html#create-pod-execution-role
#------------------------------------------------------------------------------
resource "aws_iam_role" "fargate_pod_execution_role" {
  name                  = "${var.environment_namespace}-EKSFargatePodExecutionRole"
  description           = "AWS Fargate pod execution role"
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
