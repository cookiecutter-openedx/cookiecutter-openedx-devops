#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: setup a DocumentDB MongoDB cluster with connectivity
#        to anything inside the VPN. create DNS records for master and reader.
#------------------------------------------------------------------------------ 
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  resource_name           = "${local.environment_vars.locals.environment_namespace}-mongodb"
  aws_region              = local.global_vars.locals.aws_region
  mongodb_instance_class  = local.environment_vars.locals.mongodb_instance_class
  mongodb_cluster_size    = local.environment_vars.locals.mongodb_cluster_size

  environment_domain      = local.environment_vars.locals.environment_domain
  environment_namespace   = local.environment_vars.locals.environment_namespace

  environment             = local.environment_vars.locals.environment
  platform_name           = local.global_vars.locals.platform_name
  platform_region         = local.global_vars.locals.platform_region

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
  source = "../../../components//mongodb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  resource_name         = local.resource_name
  environment_domain    = local.environment_domain
  environment_namespace = local.environment_namespace

  cluster_dns_name      = "mongodb.master"
  reader_dns_name       = "mongodb.reader"

  environment           = local.environment
  name                  = local.platform_name
  namespace             = local.platform_region
  region                = local.platform_region
  label_order           = ["stage", "environment", "name", "namespace", "attributes"]
  delimiter             = "-"

  cluster_parameters    = [
                          {"apply_method"="pending-reboot","name"="tls","value"="disabled"},
                          {"apply_method"="pending-reboot","name"="ttl_monitor","value"="disabled"}
                          ]

  master_username       = "root"
  db_port               = 27017
  deletion_protection   = false
  engine                = "docdb"
  engine_version        = "3.6.0"
  retention_period      = 7
  enabled               = true

  availability_zones    = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  instance_class        = local.mongodb_instance_class
  cluster_size          = local.mongodb_cluster_size

  id_length_limit       = 0
  label_key_case        = "title"
  label_value_case      = "lower"
  regex_replace_chars   = "/[^a-zA-Z0-9-]/"
  tenant                = ""
  stage                 = ""

  vpc_id                = dependency.vpc.outputs.vpc_id
  vpc_cidr_block        = dependency.vpc.outputs.vpc_cidr_block
  ingress_cidr_blocks   = [dependency.vpc.outputs.vpc_cidr_block]
  subnet_ids            = dependency.vpc.outputs.database_subnets
  
  enabled_cloudwatch_logs_exports = []
  storage_encrypted = false
  apply_immediately = false
  skip_final_snapshot = true
  preferred_maintenance_window = ""
  preferred_backup_window = "07:00-09:00"
  auto_minor_version_upgrade = true

  tags                  = local.tags

}

