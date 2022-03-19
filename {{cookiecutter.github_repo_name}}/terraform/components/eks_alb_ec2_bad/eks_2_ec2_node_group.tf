#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Create EKS Node Group (aka workers)
#------------------------------------------------------------------------------

# allow ssh access to anything inside the VPC
resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.environment_namespace}-eks_worker_group_mgmt"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "192.168.0.0/16",
    ]
  }

  tags = var.tags

}

# Resource: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# Create IAM role for EKS Node Group
resource "aws_iam_role" "nodes_general" {
  name = "eks-node-group-general"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

}

# Resource: aws_iam_role_policy_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_general" {
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_general" {
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes_general.name
}

resource "aws_launch_template" "eks_node" {
  name                   = "${var.environment_namespace}-eks_node"
  vpc_security_group_ids = [aws_security_group.worker_group_mgmt.id]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 25
    }
  }

  # InvalidParameterException: You cannot configure shutdown behavior. Amazon EKS will always terminate instances.
  #instance_initiated_shutdown_behavior = "terminate"

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

}

# Resource: aws_eks_node_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
# FIX NOTE. name doesn't appear in AWS Console
resource "aws_eks_node_group" "nodes_general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "ec2-node"
  node_role_arn   = aws_iam_role.nodes_general.arn
  subnet_ids      = var.private_subnet_ids

  #launch_template {
  #  id      = aws_launch_template.eks_node.id
  #  version = "1"
  #}

  scaling_config {
    desired_size = var.eks_worker_group_desired_size
    max_size     = var.eks_worker_group_max_size
    min_size     = var.eks_worker_group_min_size
  }

  # Type of Amazon Machine Image (AMI) associated with the EKS Node Group.
  # one of [AL2_x86_64 AL2_x86_64_GPU AL2_ARM_64 CUSTOM BOTTLEROCKET_ARM_64 BOTTLEROCKET_x86_64]
  ami_type = "AL2_ARM_64"

  # Type of capacity associated with the EKS Node Group.
  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # mcdaniel: pretty unintuitive error whenever you try to set this.
  # Error: error creating EKS Node Group (fargate-sandbox-ohio:ec2-node): InvalidParameterException: Disk size must be specified within the launch template.
  disk_size = 25

  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false

  # List of instance types associated with the EKS Node Group
  # FIX NOTE: WHY DOES THIS BREAK FOR t3.large?
  instance_types = [var.eks_worker_group_instance_type]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  labels = {
    role = "ec2-node"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy_general,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy_general,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
  ]

  tags = var.tags
}
