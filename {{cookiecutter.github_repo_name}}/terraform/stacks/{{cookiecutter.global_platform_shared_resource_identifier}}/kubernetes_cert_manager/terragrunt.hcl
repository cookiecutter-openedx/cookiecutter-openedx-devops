#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Mar-2022
#
# usage: build an EKS with EC2 worker nodes and ALB
#------------------------------------------------------------------------------
locals {
  stack_vars  = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  root_domain                     = local.global_vars.locals.root_domain
  shared_resource_namespace       = local.global_vars.locals.shared_resource_namespace
  aws_region                      = local.global_vars.locals.aws_region
  cert_manager_namespace          = "cert-manager"
  services_subdomain              = local.global_vars.locals.services_subdomain

  tags = merge(
    local.stack_vars.locals.tags,
  )

}

dependencies {
  paths = [
    "../vpc",
    "../kubernetes",
    "../kubernetes_vpa",
    "../kubernetes_ingress_clb",
    ]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    public_subnets   = ["fake-public-subnet-01", "fake-public-subnet-02"]
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }
}

dependency "kubernetes_ingress_clb" {
  config_path = "../kubernetes_ingress_clb"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    cluster_arn = "flake-cluster-arn"
  }
}

dependency "kubernetes_vpa" {
  config_path = "../kubernetes_vpa"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//kubernetes_cert_manager"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  root_domain                 = local.root_domain
  aws_region                  = local.aws_region
  cert_manager_namespace      = local.cert_manager_namespace
  namespace                   = local.shared_resource_namespace
  services_subdomain          = local.services_subdomain
  tags                        = local.tags
}
