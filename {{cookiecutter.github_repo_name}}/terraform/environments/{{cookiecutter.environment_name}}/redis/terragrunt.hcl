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

  environment_namespace = local.environment_vars.locals.environment_namespace
  resource_name   = "${local.environment_vars.locals.environment_namespace}"
  redis_node_type = local.environment_vars.locals.redis_node_type

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )
}

dependencies {
  paths = [
    "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/vpc",
    "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/kubernetes",
    "../kubernetes_secrets"
    ]
}

dependency "vpc" {
  config_path = "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
    elasticache_subnets = ["fake-elasticache-subnet-01", "fake-elasticache-subnet-02"]
    vpc_cidr_block = "fake-cidr-block"
  }
}

dependency "kubernetes" {
  config_path = "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    cluster_arn           = "fake-cluster-arn"
    cluster_certificate_authority_data = "fake-cert"
    cluster_endpoint = "fake-cluster-endpoint"
    cluster_id = "fake-cluster-id"
    cluster_oidc_issuer_url = "fake-oidc-issuer-url"
    cluster_platform_version = "fake-cluster-version"
    cluster_security_group_arn = "fake-security-group-arn"
    cluster_security_group_id = "fake-security-group-id"
    cluster_status = "fake-cluster-status"
    cluster_version = "fake-cluster-version"
    eks_managed_node_groups = "fake-managed-node-group"
    fargate_profiles = "fake-fargate-profile"
    node_security_group_arn = "fake-security-group-arn"
    node_security_group_id = "fake-security-group-id"
    oidc_provider = "fake-oidc-provider"
    oidc_provider_arn = "fake-provider-arn"
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  # AWS Elasticache identifying information
  environment_namespace         = local.environment_namespace
  resource_name                 = local.resource_name
  tags                          = local.tags

  # cache instance identifying information
  replication_group_description = "${local.environment_vars.locals.environment_namespace}"
  create_random_auth_token      = "false"

  # cache engine configuration
  engine                        = "redis"
  engine_version                = "{{ cookiecutter.redis_engine_version }}"
  num_cache_clusters         = {{ cookiecutter.redis_num_cache_clusters }}
  port                          = {{ cookiecutter.redis_port }}
  family                        = "{{ cookiecutter.redis_family }}"
  node_type                     = local.redis_node_type
  transit_encryption_enabled    = false

  # networking configuration
  subnet_ids                    = dependency.vpc.outputs.elasticache_subnets
  vpc_id                        = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks           = [dependency.vpc.outputs.vpc_cidr_block]

}
