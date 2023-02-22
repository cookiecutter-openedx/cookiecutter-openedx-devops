#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Feb-2023
#
# usage: deploy a Wordpress site
#------------------------------------------------------------------------------
locals {
  global_vars       = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  client_vars       = read_terragrunt_config("client.hcl")

  aws_region                = local.global_vars.locals.aws_region
  root_domain               = local.global_vars.locals.root_domain
  shared_resource_namespace = local.global_vars.locals.shared_resource_namespace
  resource_name             = local.client_vars.locals.wp_namespace
  phpmyadmin                = local.client_vars.locals.phpmyadmin

  wordpressConfig = {
    HostedZoneID   = local.client_vars.locals.wp_hosted_zone_id,
    RootDomain     = local.client_vars.locals.wp_domain,
    Domain         = "${local.client_vars.locals.wp_subdomain}.${local.client_vars.locals.wp_domain}",
    Subdomain      = local.client_vars.locals.wp_subdomain,
    Namespace      = local.client_vars.locals.wp_namespace,
    Username       = local.client_vars.locals.wp_username,
    Email          = local.client_vars.locals.wp_email,
    FirstName      = local.client_vars.locals.wp_user_firstname,
    LastName       = local.client_vars.locals.wp_user_lastname,
    BlogName       = local.client_vars.locals.wp_blog_name,
    DatabaseUser   = local.client_vars.locals.wp_database_user,
    Database       = local.client_vars.locals.wp_database,
    DiskVolumeSize = local.client_vars.locals.wp_disk_volume_size
  }

  tags = merge(
    local.global_vars.locals.tags,
    {
      "cookiecutter/environment"                = local.resource_name
      "cookiecutter/environment_subdomain"      = local.client_vars.locals.wp_subdomain
      "cookiecutter/environment_domain"         = local.client_vars.locals.wp_domain
      "cookiecutter/environment_namespace"      = local.client_vars.locals.wp_namespace
      "cookiecutter/shared_resource_namespace"  = local.shared_resource_namespace
    },
    { Name = local.resource_name }
  )
}

dependencies {
  paths = [
    "../../../stacks/service/vpc",
    "../../../stacks/service/kubernetes",
    "../../../stacks/service/mysql",
    "../../../stacks/service/redis",
    ]
}

dependency "vpc" {
  config_path = "../../../stacks/service/vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    public_subnets   = ["fake-subnetid-01", "fake-subnetid-02"]
    private_subnets  = ["fake-subnetid-01", "fake-subnetid-02"]
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
    elasticache_subnets = ["fake-elasticache-subnet-01", "fake-elasticache-subnet-02"]
    vpc_cidr_block = "fake-cidr-block"
  }
}

dependency "kubernetes" {
  config_path = "../../../stacks/service/kubernetes"

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

dependency "mysql" {
  config_path = "../../../stacks/service/mysql"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {}
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//wordpress"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  root_domain                   = local.root_domain
  shared_resource_namespace     = local.shared_resource_namespace
  aws_region                    = local.aws_region
  wordpressConfig               = local.wordpressConfig
  phpmyadmin                    = local.phpmyadmin
  tags                          = local.tags
  subnet_ids                    = dependency.vpc.outputs.private_subnets
}
