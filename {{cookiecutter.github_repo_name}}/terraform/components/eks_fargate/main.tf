#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------ 
locals {
  name = var.cluster_name
  tags = var.tags
}

#------------------------------------------------------------------------------
# Setup Kubernetes
#
# Harshet Jain:  First, we tell Terraform where our Kubernetes cluster is 
# running. For this, we need to add a kubernetes provider, like this:
#------------------------------------------------------------------------------ 
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

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

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18"
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


#------------------------------------------------------------------------------
# Harshet Jain: Create a node group
# Now we have the cluster set up and ready, but we don’t have any nodes yet to run our pods on. 
# It’s possible to run your pods without any nodes. But you need to do some 
# tweaking to the CoreDNS deployment (more on that here and here).
# So instead, we’ll create a node group for the kube-system namespace, which is
# used to run any pods necessary for operating the Kubernetes cluster. We can 
# launch the node group in the public/private subnets. 
# The setup looks as follows:
#------------------------------------------------------------------------------

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.environment_namespace}-node_group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.public_subnets

  scaling_config {
    desired_size = 2
    max_size     = 25
    min_size     = 2
  }

  instance_types  = ["${var.worker_group_instance_type}"]
}

#------------------------------------------------------------------------------
# Fargate profile
#
# Harshet Jain: In order to run pods in a Fargate (serverless) configuration, 
# we first need to create a Fargate profile. This profile defines namespaces 
# and selectors, which are used to identify which pods should be run on the 
# Fargate nodes. Make sure Fargate pods can only run in private subnets. 
#
# The setup looks as follows:
#------------------------------------------------------------------------------
resource "aws_eks_fargate_profile" "eks_fargate" {
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "${var.environment_namespace}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  subnet_ids             = var.private_subnets

  selector {
    namespace = "${var.environment_namespace}"
  }

  timeouts {
    create   = "30m"
    delete   = "30m"
  }
}