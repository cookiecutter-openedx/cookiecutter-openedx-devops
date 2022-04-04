#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create one Cloudfront distribution for the environment, plus one more
#        for each subdomain.
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  environment_namespace = local.environment_vars.locals.environment_namespace
  environment_domain    = local.environment_vars.locals.environment_domain
  aws_region            = local.global_vars.locals.aws_region

  resource_name = "${local.environment_vars.locals.environment_namespace}-storage"

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}

dependencies {
  paths = ["../vpc", "../s3_openedx_storage"]
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../modules//cloudfront"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  aws_region            = local.aws_region
  environment_namespace = local.environment_namespace
  environment_domain    = local.environment_domain
  resource_name         = local.resource_name
  tags                  = local.tags
}
