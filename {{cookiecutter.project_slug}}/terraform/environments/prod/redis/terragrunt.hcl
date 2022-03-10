#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#------------------------------------------------------------------------------ 
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  resource_name   = "${local.environment_vars.locals.environment_namespace}"
  redis_node_type = local.environment_vars.locals.redis_node_type

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )
}

terraform {
  source = "../../../components//redis"
}

dependencies {
  paths = ["../vpc", "../kubernetes"]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name = local.resource_name
  tags          = local.tags

  replication_group_description = "${local.environment_vars.locals.environment_namespace}"
  create_random_auth_token      = "false"

  # DB subnet group
  subnet_ids = dependency.vpc.outputs.elasticache_subnets


  # Security group
  vpc_id              = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]

  engine                = "redis"
  engine_version        = "6.x"
  number_cache_clusters = 1
  port                  = 6379

  # DB parameter group
  family = "redis6.x"

  node_type                  = local.redis_node_type
  transit_encryption_enabled = false
}

