#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create one Amazon certificates for the environment domain and
#        the root domain.
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  environment_domain    = local.environment_vars.locals.environment_domain
  root_domain           = local.global_vars.locals.root_domain
  environment_namespace = local.environment_vars.locals.environment_namespace
  resource_name = local.environment_vars.locals.environment_namespace
  aws_region            = local.global_vars.locals.aws_region

  tags = merge(
    local.environment_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}

dependencies {
  paths = [
    "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/vpc",
    "../vpc"
    ]
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//acm"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  aws_region            = local.aws_region
  root_domain           = local.root_domain
  environment_domain    = local.environment_domain
  environment_namespace = local.environment_namespace
  resource_name         = local.resource_name
  tags                  = local.tags
}
