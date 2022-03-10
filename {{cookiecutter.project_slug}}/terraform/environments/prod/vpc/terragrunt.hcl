#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------ 
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  environment           = local.environment_vars.locals.environment
  platform_name         = local.global_vars.locals.platform_name
  platform_region       = local.global_vars.locals.platform_region
  aws_region            = local.global_vars.locals.aws_region
  environment_namespace = local.environment_vars.locals.environment_namespace

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
  )
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "../../../components//vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  environment_namespace = local.environment_namespace
  name                  = "${local.environment_namespace}"
  cidr                  = "192.168.0.0/20"
  azs                   = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]

  public_subnets      = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_subnets     = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  database_subnets    = ["192.168.8.0/24", "192.168.9.0/24"]
  elasticache_subnets = ["192.168.10.0/24", "192.168.11.0/24"]

  enable_ipv6          = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.environment_namespace}" = "shared"
    "kubernetes.io/role/elb"                               = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.environment_namespace}" = "shared"
    "kubernetes.io/role/internal-elb"                      = "1"
  }

  tags = local.tags
}
