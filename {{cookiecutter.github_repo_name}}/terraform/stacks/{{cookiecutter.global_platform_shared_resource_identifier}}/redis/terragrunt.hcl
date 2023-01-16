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
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))

  services_subdomain        = local.global_vars.locals.services_subdomain
  resource_name             = local.stack_vars.locals.stack_namespace
  shared_resource_namespace = local.stack_vars.locals.stack_namespace
  redis_node_type           = local.stack_vars.locals.redis_node_type

  tags = merge(
    local.stack_vars.locals.tags,
    {
      "cookiecutter/name" = "${local.resource_name}"
      Name = "${local.resource_name}"
    }
  )
}

dependencies {
  paths = [
    "../vpc",
    "../kubernetes",
    ]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
    elasticache_subnets = ["fake-elasticache-subnet-01", "fake-elasticache-subnet-02"]
    vpc_cidr_block = "fake-cidr-block"
  }
}

dependency "kubernetes" {
  config_path = "../kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
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

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
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
  services_subdomain            = local.services_subdomain
  resource_name                 = local.resource_name
  shared_resource_namespace     = local.shared_resource_namespace
  tags                          = local.tags

  # cache instance identifying information
  replication_group_description = local.shared_resource_namespace
  create_random_auth_token      = "false"

  # cache engine configuration
  engine                        = "redis"
  engine_version                = "{{ cookiecutter.redis_engine_version }}"
  num_cache_clusters            = {{ cookiecutter.redis_num_cache_clusters }}
  port                          = {{ cookiecutter.redis_port }}
  family                        = "{{ cookiecutter.redis_family }}"
  node_type                     = local.redis_node_type
  transit_encryption_enabled    = false

  # networking configuration
  subnet_ids                    = dependency.vpc.outputs.elasticache_subnets
  vpc_id                        = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks           = [dependency.vpc.outputs.vpc_cidr_block]

}
