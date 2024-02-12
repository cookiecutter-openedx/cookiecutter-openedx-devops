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
# - https://repost.aws/knowledge-center/execute-user-data-ec2
#------------------------------------------------------------------------------
data "aws_partition" "current" {}

locals {
  # Used by Karpenter config to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition

  template_docker_edx_sandbox = templatefile("${path.module}/templates/docker-edx-sandbox.tpl", {})
  template_post_install_apparmor = templatefile("${path.module}/templates/post-install-apparmor.tpl", {
    docker_edx_sandbox = local.template_docker_edx_sandbox
  })

  tags = merge(
    var.tags,
    {
      "cookiecutter/module/source" = "openedx_devops/terraform/stacks/modules/kubernetes"
    }
  )

}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> {{ cookiecutter.terraform_aws_modules_eks }}"
  cluster_name                    = var.namespace
  cluster_version                 = var.kubernetes_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  create_cloudwatch_log_group     = false
  enable_irsa                     = true
  authentication_mode             = "API_AND_CONFIG_MAP"

  # NOTE:
  # larger organizations might want to change these two settings
  # in order to further restrict which IAM users have access to
  # the AWS EKS Kubernetes Secrets. Note that at cluster creation,
  # this key is benign since Kubernetes secrets encryption
  # is not enabled by default.
  #
  # AWS EKS KMS console: https://us-east-2.console.aws.amazon.com/kms/home
  #
  # audit your AWS EKS KMS key access by running:
  # aws kms get-key-policy --key-id ADD-YOUR-KEY-ID-HERE --region us-east-2 --policy-name default --output text
  create_kms_key = var.eks_create_kms_key
  kms_key_owners = var.kms_key_owners

  # add the bastion IAM user to aws-auth.mapUsers so that
  # kubectl and k9s work from inside the bastion server by default.
  create_iam_role = true

  # Cluster access entry
  # enable_cluster_creator_admin_permissions = true
  access_entries = {
    bastion = {
      kubernetes_groups = []
      principal_arn     = var.bastion_iam_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = merge(
    local.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/eks/aws"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_eks }}"
    }
  )

  cluster_addons = {
    vpc-cni = {
      addon_version = "v1.16.2-eksbuild.1"
    }
    coredns = {
      addon_version = "v1.11.1-eksbuild.6"
    }
    kube-proxy = {
      addon_version = "v1.29.0-eksbuild.2"
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.AmazonEKS_EBS_CSI_DriverRole.arn
      addon_version            = "v1.27.0-eksbuild.1"
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "cookiecutter: Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [
        "172.16.0.0/12",
        "192.168.0.0/16",
      ]
    }
    port_8443 = {
      description                = "cookiecutter: open port 8443 to vpc"
      protocol                   = "-1"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
    egress_all = {
      description      = "cookiecutter: Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  self_managed_node_group_defaults = {
    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.namespace}" : "owned",
    }
  }

  self_managed_node_groups = {
    # see: https://github.com/overhangio/tutor/issues/284
    #
    # TO DO: VERIFY THAT THIS NODE GROUP HAS THE FOLLOWING ROLE-BASED PERMISSIONS:
    # IAM Role policies for EC2 node group
    # AmazonEKSWorkerNodePolicy
    # AmazonEKS_CNI_Policy
    # AmazonEC2ContainerRegistryReadOnly

    eks_ubuntu = {
      min_size          = var.ubuntu_group_min_size
      max_size          = var.ubuntu_group_max_size
      desired_size      = var.ubuntu_group_desired_size
      ami_id            = data.aws_ami.ubuntu.id
      capacity_type     = "SPOT"
      enable_monitoring = false

      labels = {
        node-group = "ubuntu"
      }

      # TO DO: configure a taint based on existing codejail deployment lables
      # taints = [{
      #   key    = "lawrencemcdaniel.com/wordpress-only"
      #   effect = "NO_SCHEDULE"
      # }]

      # init customizations
      pre_bootstrap_user_data = <<-EOT
      EOT
      # bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      post_bootstrap_user_data = local.template_post_install_apparmor

      use_mixed_instances_policy = true
      mixed_instances_policy = {
        instances_distribution = {
          on_demand_base_capacity                  = 0
          on_demand_percentage_above_base_capacity = 0
          spot_allocation_strategy                 = "capacity-optimized"
        }

        override = [
          { instance_type = "t3.large" },
          { instance_type = "t3.xlarge" },
          { instance_type = "t3a.large" },
          { instance_type = "t3a.xlarge" },
          { instance_type = "t2.large" },
          { instance_type = "t2.xlarge" },
          { instance_type = "m4.large" },
          { instance_type = "m5.large" },
          { instance_type = "m5a.large" },
          { instance_type = "m5ad.large" },
          { instance_type = "m5d.large" },
          { instance_type = "m5dn.large" },
          { instance_type = "m5n.large" },
          { instance_type = "m5zn.large" },
          { instance_type = "m6a.large" },
          { instance_type = "m6i.large" },
          { instance_type = "m6id.large" },
          { instance_type = "m6idn.large" },
          { instance_type = "m6in.large" },
          { instance_type = "m7a.large" },
          { instance_type = "m7a.xlarge" },
          { instance_type = "m7i-flex.large" },
          { instance_type = "m7i.large" },
          { instance_type = "r3.large" },
          { instance_type = "r4.large" },
          { instance_type = "r5.large" },
          { instance_type = "r5a.large" },
          { instance_type = "r5ad.large" },
          { instance_type = "r5b.large" },
          { instance_type = "r5d.large" },
          { instance_type = "r5dn.large" },
          { instance_type = "r5n.large" },
          { instance_type = "r6a.large" },
          { instance_type = "r6i.large" },
          { instance_type = "r6id.large" },
          { instance_type = "r6idn.large" },
          { instance_type = "r6in.large" },
        ]

      }


      iam_role_additional_policies = {
        # see https://ubuntu.com/blog/introducing-ubuntu-support-for-amazon-eks-1-18
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }
      block_device_mappings = {
        sda1 = {
          device_name = "/dev/sda1"
          ebs = {
            volume_type           = "gp3"
            volume_size           = 100
            delete_on_termination = true
          }
        }
      }

      tags = local.tags

    }
  }
  eks_managed_node_groups = {
    # This node group is managed by Karpenter. There must be at least
    # node in this group at all times in order for Karpenter to monitor
    # load and act on metrics data. Karpenter's bin packing algorithms
    # perform more effectively with larger instance types. The Cookiecutter
    # default instance type is t3.xlarge (4 vCPU / 16 GiB). These instances,
    # beyond the 1 permanent instance, are assumed to be short-lived
    # (a few hours or less) as these are usually only instantiated during
    # bursts of user activity such as at the start of a scheduled lecture or
    # exam on a large mooc.
    eks_amazn = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.service_group_desired_size
      min_size          = var.service_group_min_size
      max_size          = var.service_group_max_size

      labels = {
        node-group = "service"
      }
      iam_role_additional_policies = {
        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }

      # Top 40 list of instance types with
      #   - x86_64 / amd64 cpu architecture
      #   - 8 <= Memory <= 16
      #   - 2 <= vCPU <= 4
      instance_types = [
        "t3.large",
        "t3.xlarge",
        "t3a.large",
        "t3a.xlarge",
        "t2.large",
        "t2.xlarge",
        "m4.large",
        "m5.large",
        "m5a.large",
        "m5ad.large",
        "m5d.large",
        "m5dn.large",
        "m5n.large",
        "m5zn.large",
        "m6a.large",
        "m6i.large",
        "m6id.large",
        "m6idn.large",
        "m6in.large",
        "m7a.large",
        "m7a.xlarge",
        "m7i-flex.large",
        "m7i.large",
        "r3.large",
        "r4.large",
        "r5.large",
        "r5a.large",
        "r5ad.large",
        "r5b.large",
        "r5d.large",
        "r5dn.large",
        "r5n.large",
        "r6a.large",
        "r6i.large",
        "r6id.large",
        "r6idn.large",
        "r6in.large",
      ]

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type           = "gp3"
            volume_size           = 100
            delete_on_termination = true
          }
        }
      }

      tags = merge(
        local.tags,
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { Name = "eks-${var.shared_resource_identifier}-service" },
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        {
          "karpenter.sh/discovery" = var.namespace
        },
      )
    }

    # a 2-node managed node group with a taint to limit workloads to Wordpress pods only.
    # node is constricted to a single availability zone by taking the 1st element of the
    # EKS private_subnet_ids list as the only subnet to add to subnet_ids.
    wordpress = {
      capacity_type     = "SPOT"
      enable_monitoring = false
      desired_size      = var.hosting_group_desired_size
      min_size          = var.hosting_group_min_size
      max_size          = var.hosting_group_max_size
      subnet_ids        = [element(var.private_subnet_ids, 0)]
      labels = {
        node-group = "wordpress"
      }
      taints = [{
        key    = "lawrencemcdaniel.com/wordpress-only"
        effect = "NO_SCHEDULE"
      }]

      iam_role_additional_policies = {
        # Required by Karpenter
        AmazonSSMManagedInstanceCore = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"

        # Required by EBS CSI Add-on
        AmazonEBSCSIDriverPolicy = data.aws_iam_policy.AmazonEBSCSIDriverPolicy.arn
      }

      # complete list of instance types with
      #   - x86_64 / amd64 cpu architecture
      #   - 8 <= Memory <= 16
      #   - vCPU == 4
      instance_types = [
        "t3.xlarge",
        "t3a.xlarge",
        "t2.xlarge",
        "c5.xlarge",
        "c5a.xlarge",
        "c5ad.xlarge",
        "c5d.xlarge",
        "c5n.xlarge",
        "c6a.xlarge",
        "c6i.xlarge",
        "c6id.xlarge",
        "c6in.xlarge",
        "m4.xlarge",
        "m5.xlarge",
        "m5a.xlarge",
        "m5ad.xlarge",
        "m5d.xlarge",
        "m5dn.xlarge",
        "m5n.xlarge",
        "m5zn.xlarge",
        "m6a.xlarge",
        "m6i.xlarge",
        "m6id.xlarge",
        "m6idn.xlarge",
        "m6in.xlarge",
        "m7a.xlarge",
        "m7i-flex.xlarge",
        "m7i.xlarge",
      ]

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_type           = "gp3"
            volume_size           = 100
            delete_on_termination = true
          }
        }
      }

      tags = merge(
        local.tags,
        # Tag node group resources for Karpenter auto-discovery
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        { Name = "eks-${var.shared_resource_identifier}-wordpress" },
      )
    }

  }
}

#==============================================================================
#                             SUPPORTING RESOURCES
#==============================================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    # https://aws.amazon.com/marketplace/server/procurement?productId=prod-lg73jq6vy35h2
    values = ["ubuntu-eks/k8s_1.29/images/hvm-ssd/ubuntu-jammy-22.04-amd64*"]
  }
}

resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${var.namespace}-eks_hosting_group_mgmt"
  description = "cookiecutter: Ingress CLB worker group management"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = merge(
    local.tags,
    { Name = "eks-${var.shared_resource_identifier}-worker_group_mgmt" },
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "5.35"
    }
  )
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "${var.namespace}-eks_all_worker_management"
  description = "cookiecutter: Ingress CLB worker management"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: Ingress CLB"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = merge(
    local.tags,
    { Name = "eks-${var.shared_resource_identifier}-all_worker_mgmt" },
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "5.35"
    }
  )
}



resource "kubernetes_namespace" "namespace-shared" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.eks]
}

resource "kubernetes_namespace" "wordpress" {
  metadata {
    name = "wordpress"
  }
  depends_on = [module.eks]
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
