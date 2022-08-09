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

  resource_name             = local.environment_vars.locals.shared_resource_namespace
  environment_domain        = local.environment_vars.locals.environment_domain
  environment_namespace     = local.environment_vars.locals.environment_namespace
  shared_resource_namespace = local.environment_vars.locals.shared_resource_namespace
  environment               = local.environment_vars.locals.environment
  db_prefix                 = local.environment_vars.locals.db_prefix
}

dependencies {
  paths = [
    "../../../stacks/live/vpc",
    "../../../stacks/live/kubernetes",
    "../../../stacks/live/mysql",
    "../kubernetes_secrets"
  ]
}

dependency "vpc" {
  config_path = "../../../stacks/live/vpc"

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

dependency "mysql" {
  config_path = "../../../stacks/live/mysql"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    db_instance_id = "fake-rds-instance-id"
  }

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//mysql"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  # AWS RDS instance identifying information
  db_prefix                 = local.db_prefix
  db_instance_id            = dependency.mysql.outputs.db_instance_id
  resource_name             = local.resource_name
  environment_domain        = local.environment_domain
  environment_namespace     = local.environment_namespace
  shared_resource_namespace = local.shared_resource_namespace
}
