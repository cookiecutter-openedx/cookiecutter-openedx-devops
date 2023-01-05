#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Mar-2022
#
# usage: build an EKS with EC2 worker nodes and ALB
#------------------------------------------------------------------------------
locals {
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  namespace                       = local.stack_vars.locals.stack_namespace
  root_domain                     = local.global_vars.locals.root_domain
  platform_name                   = local.global_vars.locals.platform_name
  platform_region                 = local.global_vars.locals.platform_region
  account_id                      = local.global_vars.locals.account_id
  aws_region                      = local.global_vars.locals.aws_region

  tags = merge(
    local.stack_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.namespace}-eks-ingress" }
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
  source = "../../modules//kubernetes_ingress_clb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  aws_region = local.aws_region
  namespace = local.namespace
  root_domain = local.root_domain
  tags = local.tags
}