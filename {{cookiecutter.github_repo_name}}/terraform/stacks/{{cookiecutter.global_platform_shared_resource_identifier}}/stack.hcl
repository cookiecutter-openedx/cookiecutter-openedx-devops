#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create stack-level parameters, exposed to all
#        Terragrunt modules in this enironment.
#------------------------------------------------------------------------------
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  stack           = local.global_vars.locals.shared_resource_identifier
  stack_namespace = "${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}-${local.global_vars.locals.shared_resource_identifier}"

  # AWS instance sizing
  mysql_instance_class      = "{{ cookiecutter.mysql_instance_class }}"
  mysql_allocated_storage   ={{ cookiecutter.mysql_allocated_storage }}

  redis_node_type           = "{{ cookiecutter.redis_node_type }}"

  {% if cookiecutter.stack_add_remote_mongodb|upper == "Y" -%}
  # MongoDB EC2 instance sizing
  mongodb_instance_type     = "{{ cookiecutter.mongodb_instance_type }}"
  mongodb_allocated_storage = {{ cookiecutter.mongodb_allocated_storage }}
  {% endif %}

  {% if cookiecutter.stack_add_bastion|upper == "Y" -%}
  # Bastion EC2 instance sizing
  bastion_instance_type     = "{{ cookiecutter.bastion_instance_type }}"
  bastion_allocated_storage = {{ cookiecutter.bastion_allocated_storage }}
  {% endif %}

  #----------------------------------------------------------------------------
  # AWS Elastic Kubernetes service
  # Scaling options
  #
  # see: https://aws.amazon.com/ec2/instance-types/
  #----------------------------------------------------------------------------
  kubernetes_version                = "{{ cookiecutter.kubernetes_cluster_version }}"
  {% if cookiecutter.eks_create_kms_key|upper == "Y" -%}
  eks_create_kms_key                = true
  {% else -%}
  eks_create_kms_key                = false
  {% endif -%}
  eks_worker_group_instance_type    = "{{ cookiecutter.eks_worker_group_instance_type }}"
  eks_worker_group_min_size         = {{ cookiecutter.eks_worker_group_min_size }}
  eks_worker_group_max_size         = {{ cookiecutter.eks_worker_group_max_size }}
  eks_worker_group_desired_size     = {{ cookiecutter.eks_worker_group_desired_size }}

  eks_karpenter_group_instance_type = "{{ cookiecutter.eks_karpenter_group_instance_type }}"
  eks_karpenter_group_min_size      = {{ cookiecutter.eks_karpenter_group_min_size }}
  eks_karpenter_group_max_size      =  {{ cookiecutter.eks_karpenter_group_max_size }}
  eks_karpenter_group_desired_size  =  {{ cookiecutter.eks_karpenter_group_desired_size }}

  tags = merge(
    local.global_vars.locals.tags,
    {
      "cookiecutter/stack"             = local.stack
      "cookiecutter/stack_namespace"   = local.stack_namespace
    }
  )
}
