#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an RDS MySQL instance.
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  stack_vars  = read_terragrunt_config(find_in_parent_folders("stack.hcl"))

  services_subdomain      = local.global_vars.locals.services_subdomain
  resource_name           = local.stack_vars.locals.stack_namespace
  mysql_instance_class    = local.stack_vars.locals.mysql_instance_class
  mysql_allocated_storage = local.stack_vars.locals.mysql_allocated_storage

  tags = merge(
    local.stack_vars.locals.tags,
    { "cookiecutter/name" = "${local.resource_name}" }
  )

}

dependencies {
  paths = ["../kubernetes", "../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
    vpc_cidr_block   = "fake-cidr-block"
  }
}

dependency "kubernetes" {
  config_path = "../kubernetes"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    cluster_arn                        = "fake-cluster-arn"
    cluster_certificate_authority_data = "fake-cert"
    cluster_endpoint                   = "fake-cluster-endpoint"
    cluster_id                         = "fake-cluster-id"
    cluster_oidc_issuer_url            = "fake-oidc-issuer-url"
    cluster_platform_version           = "fake-cluster-version"
    cluster_security_group_arn         = "fake-security-group-arn"
    cluster_security_group_id          = "fake-security-group-id"
    cluster_status                     = "fake-cluster-status"
    cluster_version                    = "fake-cluster-version"
    eks_managed_node_groups            = "fake-managed-node-group"
    fargate_profiles                   = "fake-fargate-profile"
    node_security_group_arn            = "fake-security-group-arn"
    node_security_group_id             = "fake-security-group-id"
    oidc_provider                      = "fake-oidc-provider"
    oidc_provider_arn                  = "fake-provider-arn"
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//mysql"
  before_hook "before_init" {
    commands = ["init"]
    execute  = ["echo", "Initializing module in ${get_terragrunt_dir()}"]
  }
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # AWS RDS instance identifying information
  services_subdomain = local.services_subdomain
  resource_name      = local.resource_name
  tags               = local.tags

  # database identifying information
  username                            = "root"
  create_random_password              = true
  iam_database_authentication_enabled = false

  # db server parameters
  port                 = "3306"
  engine               = "mysql"
  engine_version       = "5.7.42"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  # db server size
  instance_class                        = local.mysql_instance_class
  allocated_storage                     = local.mysql_allocated_storage
  max_allocated_storage                 = 1000
  storage_encrypted                     = false
  multi_az                              = false
  enabled_cloudwatch_logs_exports       = []
  performance_insights_enabled          = false
  performance_insights_retention_period = 7
  create_monitoring_role                = false
  monitoring_interval                   = 0
  create_db_subnet_group                = false

  # backups and maintenance
  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = true


  # network configuration
  subnet_ids          = dependency.vpc.outputs.database_subnets
  vpc_id              = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]

}
