#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Create EKS Node Group (aka workers)
#------------------------------------------------------------------------------



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

# Resource: aws_iam_role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# Create IAM role for EKS Node Group
resource "aws_iam_role" "nodes_general" {
  # The name of the role
  name = "eks-node-group-general"

  # The policy that grants an entity permission to assume the role.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Resource: aws_iam_role_policy_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy_general" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKSWorkerNodePolicy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

  # The role the policy should be applied to
  role = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy_general" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEKS_CNI_Policy
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

  # The role the policy should be applied to
  role = aws_iam_role.nodes_general.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  # The ARN of the policy you want to apply.
  # https://github.com/SummitRoute/aws_managed_policies/blob/master/policies/AmazonEC2ContainerRegistryReadOnly
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

  # The role the policy should be applied to
  role = aws_iam_role.nodes_general.name
}


resource "aws_launch_template" "eks_node" {
  name                                 = "eks_node"
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "a1.medium"
  kernel_id                            = "eks_node"
  key_name                             = "eks_node"
  vpc_security_group_ids = [
    aws_security_group.worker_group_mgmt,
    aws_security_group.all_worker_mgmt
  ]

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 25
    }
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  placement {
    availability_zone = var.aws_region
  }

  #ram_disk_id = "test"

  #cpu_options {
  #  core_count       = 4
  #  threads_per_core = 2
  #}

  #credit_specification {
  #  cpu_credits = "standard"
  #}
  #instance_market_options {
  #  market_type = "spot"
  #}

  #license_specification {
  #  license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  #}

  #metadata_options {
  #  http_endpoint               = "enabled"
  #  http_tokens                 = "required"
  #  http_put_response_hop_limit = 1
  #  instance_metadata_tags      = "enabled"
  #}

  #user_data = filebase64("${path.module}/example.sh")

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

}

# Resource: aws_eks_node_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
# FIX NOTE. name doesn't appear in AWS Console
resource "aws_eks_node_group" "nodes_general" {
  # Name of the EKS Cluster.
  cluster_name = aws_eks_cluster.eks.name

  # Name of the EKS Node Group.
  node_group_name = "nodes-general"
  launch_template = aws_launch_template.eks_node

  # Amazon Resource Name (ARN) of the IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = aws_iam_role.nodes_general.arn

  # Identifiers of EC2 Subnets to associate with the EKS Node Group.
  # These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME
  # (where CLUSTER_NAME is replaced with the name of the EKS Cluster).
  subnet_ids = var.private_subnet_ids

  # Configuration block with scaling settings

  scaling_config {
    # Desired number of worker nodes.
    desired_size = var.eks_worker_group_desired_size

    # Maximum number of worker nodes.
    max_size = var.eks_worker_group_max_size

    # Minimum number of worker nodes.
    min_size = var.eks_worker_group_min_size
  }

  # Type of Amazon Machine Image (AMI) associated with the EKS Node Group.
  # one of [AL2_x86_64 AL2_x86_64_GPU AL2_ARM_64 CUSTOM BOTTLEROCKET_ARM_64 BOTTLEROCKET_x86_64]
  ami_type = "AL2_ARM_64"

  # Type of capacity associated with the EKS Node Group.
  # Valid values: ON_DEMAND, SPOT
  capacity_type = "ON_DEMAND"

  # Disk size in GiB for worker nodes
  disk_size = 25

  # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
  force_update_version = false

  # List of instance types associated with the EKS Node Group
  # FIX NOTE: WHY DOES THIS BREAK FOR t3.large?
  #instance_types = [var.eks_worker_group_instance_type]
  # Optional: Allow external changes without Terraform plan difference

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  labels = {
    role = "nodes-general"
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
