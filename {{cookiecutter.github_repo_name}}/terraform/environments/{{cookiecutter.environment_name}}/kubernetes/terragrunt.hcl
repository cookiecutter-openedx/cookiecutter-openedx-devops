#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Mar-2022
#
# usage: build an EKS with EC2 worker nodes and ALB
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  resource_name = local.environment_vars.locals.shared_resource_namespace
  environment_name = local.environment_vars.locals.environment
}

dependency "vpc" {
  config_path = "../../../stacks/{{ cookiecutter.global_platform_shared_resource_identifier }}/vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    public_subnets   = ["fake-public-subnet-01", "fake-public-subnet-02"]
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//kubernetes"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  environment_name = local.environment_name
  resource_name = local.resource_name
}
