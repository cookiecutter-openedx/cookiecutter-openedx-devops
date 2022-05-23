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

  environment = local.environment_vars.locals.environment
  resource_name   = local.environment_vars.locals.shared_resource_namespace
  redis_node_type = local.environment_vars.locals.redis_node_type

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )
}

terraform {
  source = "../../modules//redis"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  # AWS Elasticache identifying information
  resource_name                 = local.resource_name
  environment                   = local.environment
  tags                          = local.tags

  # cache instance identifying information
  replication_group_description = "${local.environment_vars.locals.environment_namespace}"
  create_random_auth_token      = "false"

  # cache engine configuration
  engine                        = "redis"
  engine_version                = "6.x"
  num_cache_clusters            = 1
  port                          = 6379
  family                        = "redis6.x"
  node_type                     = local.redis_node_type
  transit_encryption_enabled    = false

}
