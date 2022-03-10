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
  source = "../../../components//mysql"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name = local.resource_name
  tags          = local.tags

  identifier = "${local.resource_name}"

  name              = "openedx"
  username          = "root"
  port              = "3306"
  engine            = "mysql"
  engine_version    = "5.7.33"
  instance_class    = local.mysql_instance_class
  allocated_storage = 10

  create_random_password              = "true"
  iam_database_authentication_enabled = false

  maintenance_window = "Sun:00:00-Sun:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 7

  # DB subnet group
  subnet_ids = dependency.vpc.outputs.database_subnets

  # Security group
  vpc_id              = dependency.vpc.outputs.vpc_id
  ingress_cidr_blocks = [dependency.vpc.outputs.vpc_cidr_block]

  # DB parameter group
  family = "mysql5.7"
  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true
  # Custom DB parameters
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
}

