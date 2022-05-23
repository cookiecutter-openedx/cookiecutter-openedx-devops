#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  environment_domain = local.env_vars.locals.environment_domain

  tags = merge(
    local.env_vars.locals.tags,
    local.global_vars.locals.tags,
  )
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "../../modules//vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  environment_domain = local.environment_domain
  tags = local.tags
}
