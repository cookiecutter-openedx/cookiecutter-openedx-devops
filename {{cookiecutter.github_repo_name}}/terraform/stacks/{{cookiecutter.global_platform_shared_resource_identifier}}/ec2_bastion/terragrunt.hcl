#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  root_domain      = local.global_vars.locals.root_domain
  aws_region       = local.global_vars.locals.aws_region
  resource_name    = local.stack_vars.locals.stack_namespace
  stack_namespace = local.stack_vars.locals.stack_namespace

  tags = merge(
    local.stack_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id                     = "fake-vpc-id"
    public_subnets             = ["fake-public-subnet-01", "fake-public-subnet-02"]
    public_subnets_cidr_blocks = ["fake-subnet-cidr-block-01", "fake-subnet-cidr-block-01"]
    security_group_name_prefix = "fake-group-name-prefix"
  }
}

dependency "kubernetes" {
  config_path = "../kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    cluster_arn           = "fake-cluster-arn"
    cluster_certificate_authority_data = "fake-cert"
    cluster_endpoint = "fake-cluster-endpoint"
    cluster_id = "fake-cluster-id"
    cluster_oidc_issuer_url = "fake-oidc-issuer-url"
    cluster_platform_version = "fake-cluster-version"
    cluster_security_group_arn = "fake-security-group-arn"
    cluster_security_group_id = "fake-security-group-id"
    cluster_status = "fake-cluster-status"
    cluster_version = "fake-cluster-version"
    eks_managed_node_groups = "fake-managed-node-group"
    fargate_profiles = "fake-fargate-profile"
    node_security_group_arn = "fake-security-group-arn"
    node_security_group_id = "fake-security-group-id"
    oidc_provider = "fake-oidc-provider"
    oidc_provider_arn = "fake-provider-arn"
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//ec2_bastion"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# -----------------------------------------------------------------------------



# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  root_domain      = local.root_domain
  resource_name    = local.resource_name
  stack_namespace  = local.stack_namespace
  vpc_id            = dependency.vpc.outputs.vpc_id
  availability_zone = "${local.aws_region}a"
  ingress_cidr_blocks = dependency.vpc.outputs.public_subnets_cidr_blocks
  security_group_name_prefix = local.resource_name

  # FIX NOTE: how to choose only one subnet????
  subnet_id = dependency.vpc.outputs.public_subnets[0]
  tags      = local.tags

}
