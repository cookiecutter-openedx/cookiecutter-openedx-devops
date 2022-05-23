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

  environment               = "prod"
  environment_subdomain     = "app"
  environment_domain        = "${local.environment_subdomain}.${local.global_vars.locals.root_domain}"
  environment_namespace     = "${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}-${local.environment}"
  shared_resource_namespace = "${local.global_vars.locals.platform_name}-${local.global_vars.locals.platform_region}-${local.global_vars.locals.shared_resource_identifier}"


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
  # About AWS EC2 a1 series virtual servers:
  # ----------------------------------------
  # Amazon EC2 A1 instances deliver significant cost savings and are ideally
  # suited for scale-out and Arm-based workloads that are supported by the
  # extensive Arm ecosystem. A1 instances are the first EC2 instances powered
  # by AWS Graviton Processors that feature 64-bit Arm Neoverse cores and custom
  # silicon designed by AWS.
  #
  #   a1.medium:     1 vCPU 2gb
  #   a1.large:      2 vCPU 4gb
  #   a1.xlarge:     4 vCPU 8gb
  #   a1.2xlarge:    8 vCPU 16gb
  #   a1.4xlarge:   16 vCPU 32gb
  #   a1.metal:     16 physical cpus 32gb
  #
  # see: https://aws.amazon.com/ec2/instance-types/
  #----------------------------------------------------------------------------
  kubernetes_version = "1.22"
  eks_worker_group_instance_type = "t3.large"
  eks_worker_group_min_size = 1
  eks_worker_group_max_size = 2
  eks_worker_group_desired_size = 1

  tags = {
    Environment = local.environment
  }

}
