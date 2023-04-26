#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:   Apr-2023
#
# usage:  implement AWS Simple Email Service for this environment.
#         https://aws.amazon.com/ses/
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  resource_name         = local.environment_vars.locals.shared_resource_namespace
  environment_domain    = local.environment_vars.locals.environment_domain
  environment_namespace = local.environment_vars.locals.environment_namespace
  aws_region            = local.global_vars.locals.aws_region

  tags = merge(
    local.environment_vars.locals.tags,
    {}
  )
}

dependencies {
  paths = [
    "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/vpc"
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


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "../../modules//ses"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name           = local.resource_name
  environment_namespace   = local.environment_namespace
  environment_domain      = local.environment_domain
  aws_region              = local.aws_region
  tags                    = local.tags
}
