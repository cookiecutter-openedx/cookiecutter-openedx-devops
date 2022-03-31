#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an RDS MySQL instance.
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  resource_name         = "${local.environment_vars.locals.environment_namespace}"
  mysql_instance_class  = local.environment_vars.locals.mysql_instance_class

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.resource_name}" }
  )

}

dependencies {
  paths = ["../vpc", "../kubernetes"]
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    database_subnets = ["fake-subnetid-01", "fake-subnetid-02"]
  }
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../modules//mysql"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # AWS RDS instance identifying information
  resource_name         = local.resource_name
  tags                  = local.tags
  identifier            = "${local.resource_name}"

  # database identifying information
  name                                = "openedx"
  username                            = "{{ cookiecutter.mysql_username }}"
  create_random_password              = {{ cookiecutter.mysql_create_random_password }}
  iam_database_authentication_enabled = {{ cookiecutter.mysql_iam_database_authentication_enabled }}

  # db server parameters
  port                  = "{{ cookiecutter.mysql_port }}"
  engine                = "{{ cookiecutter.mysql_engine }}"
  engine_version        = "{{ cookiecutter.mysql_engine_version }}"
  family                = "{{ cookiecutter.mysql_family }}"
  major_engine_version  = "{{ cookiecutter.mysql_major_engine_version }}"
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
  instance_class        = local.mysql_instance_class
  allocated_storage     = {{ cookiecutter.mysql_allocated_storage }}
  max_allocated_storage = 0
  storage_encrypted     = true
  multi_az              = false
  enabled_cloudwatch_logs_exports = false
  performance_insights_enabled = false
  performance_insights_retention_period = 7
  create_monitoring_role = false
  monitoring_interval = 0


  # backups and maintenance
  maintenance_window    = "{{ cookiecutter.mysql_maintenance_window }}"
  backup_window         = "{{ cookiecutter.mysql_backup_window }}"
  backup_retention_period = {{ cookiecutter.mysql_backup_retention_period }}
  deletion_protection   = {{ cookiecutter.mysql_deletion_protection }}
  skip_final_snapshot   = {{ cookiecutter.mysql_skip_final_snapshot }}


  # network configuration
  subnet_ids            = dependency.vpc.outputs.database_subnets
  vpc_id                = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks   = [dependency.vpc.outputs.vpc_cidr_block]

}
