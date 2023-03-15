#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a detachable EBS volume to be used as the primary storage
#        volume for MongoDB.
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  stack_namespace           = local.stack_vars.locals.stack_namespace
  mongodb_allocated_storage = local.stack_vars.locals.mongodb_allocated_storage

  tags = merge(
    local.stack_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.stack_namespace}-mongodb" }
  )

}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
    vpc_cidr_block = "fake-cidr-block"
  }
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//mongodb_volume"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  allocated_storage     = local.mongodb_allocated_storage
  tags                  = local.tags
  subnet_ids            = dependency.vpc.outputs.database_subnets
  tags = local.tags
}
