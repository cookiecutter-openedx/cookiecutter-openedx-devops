#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: jan-2023
#
# usage: install Kubernetes Dashboard web app
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars      = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars     = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  dashboard_namespace             = "kube-dashboard"
  dashboard_account_name          = "admin-user"
  stack_namespace                 = local.stack_vars.locals.stack_namespace

  tags = merge(
    local.stack_vars.locals.tags,
    { Name = "${local.stack_namespace}-dashboard" }
  )
}

dependencies {
  paths = [
    "../vpc",
    "../kubernetes",
    "../kubernetes_ingress_clb",
    "../kubernetes_cert_manager",
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

dependency "kubernetes" {
  config_path = "../kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
  mock_outputs = {
    service_node_group_iam_role_name = "fake-karpenter-node-group-iam-role-name"
    service_node_group_iam_role_arn  = "fake-karpenter-node-group-iam-role-arn"
  }

}

dependency "kubernetes_ingress_clb" {
  config_path = "../kubernetes_ingress_clb"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
  mock_outputs = {
    cluster_arn = "fake-cluster-arn"
  }

}

dependency "kubernetes_cert_manager" {
  config_path = "../kubernetes_cert_manager"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
  mock_outputs = {
    cert_manager_policy = "fake-cert-manager-policy-arn"
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//kubernetes_dashboard"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  dashboard_namespace = local.dashboard_namespace
  dashboard_account_name = local.dashboard_account_name
  stack_namespace = local.stack_namespace
  tags = local.tags
}
