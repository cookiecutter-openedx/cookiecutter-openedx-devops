#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a remote MongoDB server running on a single EC2 instance.
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  stack_namespace           = local.stack_vars.locals.stack_namespace
  mongodb_instance_type     = local.stack_vars.locals.mongodb_instance_type
  mongodb_allocated_storage = local.stack_vars.locals.mongodb_allocated_storage
  platform_name             = local.global_vars.locals.platform_name
  services_subdomain        = local.global_vars.locals.services_subdomain
  aws_region                = local.global_vars.locals.aws_region
  resource_name             = "${local.stack_namespace}-mongodb"

  tags = merge(
    local.stack_vars.locals.tags,
    { Name = local.resource_name }
  )

}

dependencies {
  paths = ["../kubernetes", "../vpc", "../ec2_bastion", "../mongodb_volume"]
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

dependency "kubernetes" {
  config_path = "../kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
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

dependency "bastion" {

  config_path = "../ec2_bastion"
  skip_outputs = true

  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {}
}

dependency "mongodb_volume" {

  config_path = "../mongodb_volume"
  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    mongodb_volume_id = "fake-volume-id"
    mongodb_volume_arn = "fake-volume-arn"
    mongodb_volume_availability_zone = "fake-volume-az"
    mongodb_volume_subnet_id = "fake-volume-subnet"
    mongodb_volume_size = "fake-volume-size"
    mongodb_volume_tags = {}
    mongodb_volume_multi_attach_enabled = false
    mongodb_volume_iops = 100
    mongodb_volume_throughput = "fake-volume-throughput"
    mongodb_volume_type = "gp2"
  }
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//mongodb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  platform_name         = local.platform_name
  services_subdomain    = local.services_subdomain
  aws_region            = local.aws_region
  stack_namespace       = local.stack_namespace
  resource_name         = local.resource_name
  username              = "admin"
  port                  = "27017"
  subnet_id             = dependency.mongodb_volume.outputs.mongodb_volume_subnet_id
  vpc_id                = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks   = [dependency.vpc.outputs.vpc_cidr_block]
  availability_zone     = dependency.mongodb_volume.outputs.mongodb_volume_availability_zone
  instance_type         = local.mongodb_instance_type
  allocated_storage     = local.mongodb_allocated_storage
  tags                  = local.tags
}
