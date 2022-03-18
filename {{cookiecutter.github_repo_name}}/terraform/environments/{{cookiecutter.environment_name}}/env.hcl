#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create environment-level parameters, exposed to all
#        Terragrunt modules in this enironment.
#------------------------------------------------------------------------------
locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment           = "{{ cookiecutter.environment_name }}"
  environment_subdomain = "{{ cookiecutter.environment_subdomain }}"
  subdomains            = []
  environment_domain    = "${local.environment_subdomain}.${local.global_vars.locals.root_domain}"
  environment_namespace = "${local.environment}-${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}"


  # AWS infrastructure sizing
  # 2 vCPU 4gb
  mongodb_instance_class = "db.t3.medium"
  mongodb_cluster_size   = 1

  # 1 vCPU 2gb
  mysql_instance_class = "db.t2.small"

  # 1 vCPU 1.55gb
  redis_node_type = "cache.t2.small"

  #----------------------------------------------------------------------------
  # AWS Elastic Kubernetes service
  # Scaling options
  #
  # valid options: a1.medium, a1.large, a1.xlarge, a1.2xlarge, a1.4xlarge, a1.metal
  # a1.medium:   1 vCPU 2gb
  # a1.large:    2 vCPU 4gb
  # a1.xlarge:   4 vCPU 8gb
  # a1.2xlarge:  8 vCPU 16gb
  # a1.4xlarge: 16 vCPU 32gb
  # a1.metal:   16 physical cpus 32gb
  #----------------------------------------------------------------------------
  eks_worker_group_instance_type = "a1.medium"
  eks_worker_group_min_size = 1
  eks_worker_group_max_size = 2
  eks_worker_group_desired_size = 1

  tags = {
    Environment = local.environment
  }

}
