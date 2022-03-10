#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a non-public S3 Bucket to store data backups from any backend 
#        service.
#------------------------------------------------------------------------------ 
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  environment           = local.environment_vars.locals.environment
  environment_namespace = local.environment_vars.locals.environment_namespace
  aws_region            = local.global_vars.locals.aws_region

  resource_name = "${local.environment_vars.locals.environment_namespace}-data-backup"

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}

dependencies {
  paths = ["../eks", "../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id                     = "fake-vpc-id"
    public_subnets             = ["fake-public-subnet-01", "fake-public-subnet-02"]
    public_subnets_cidr_blocks = ["fake-subnet-cidr-block-01", "fake-subnet-cidr-block-01"]
    security_group_name_prefix = "fake-group-name-prefix"
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../components//data_backup_s3"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  secret_name   = "s3-data-backup-${local.environment}"
  aws_region    = "${local.aws_region}"
  resource_name = local.resource_name
  tags          = local.tags
}
