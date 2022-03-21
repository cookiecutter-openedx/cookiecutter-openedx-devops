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
  aws_region                      = local.global_vars.locals.aws_region

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.environment_namespace}-alb" }
  )
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }

}

dependency "eks" {
  config_path = "../eks"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../modules//eks_ingress_alb_controller"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  environment_namespace = local.environment_namespace
  environment_domain = local.environment_domain
  aws_region = local.aws_region
  vpc_id  = dependency.vpc.outputs.vpc_id
  k8s_namespace = "ingress-alb"
  tags = local.tags
}
