#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an AWS S3 bucket to offload Open edX file storage.
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  kubernetes_name       = local.environment_vars.locals.shared_resource_namespace
  aws_region            = local.global_vars.locals.aws_region
  resource_name         = "${local.environment_vars.locals.environment_namespace}-storage"
  environment         = local.environment_vars.locals.environment

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//s3_openedx_storage"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  secret_name     = "s3-openedx-storage"
  environment     = local.environment
  aws_region      = "${local.aws_region}"
  resource_name   = local.resource_name
  kubernetes_name = local.kubernetes_name
  tags            = local.tags

}
