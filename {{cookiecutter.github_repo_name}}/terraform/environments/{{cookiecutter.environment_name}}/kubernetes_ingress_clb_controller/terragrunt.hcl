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

  # Extract out common variables for reuse
  environment_domain              = local.environment_vars.locals.environment_domain
  environment_namespace           = local.environment_vars.locals.environment_namespace
  subdomains                      = local.environment_vars.locals.subdomains

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.environment_namespace}-clb" }
  )
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }

}

dependency "kubernetes" {
  config_path = "../kubernetes"
}

terraform {
  source = "../../../modules//kubernetes_ingress_clb_controller"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  environment_domain = local.environment_domain
  environment_namespace = local.environment_namespace
  subdomains = local.subdomains
  tags = local.tags
}
