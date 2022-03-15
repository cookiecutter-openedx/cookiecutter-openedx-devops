#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS Fargate cluster
#------------------------------------------------------------------------------ 
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  env                             = local.environment_vars.locals.environment
  environment_domain              = local.environment_vars.locals.environment_domain
  platform_name                   = local.global_vars.locals.platform_name
  platform_region                 = local.global_vars.locals.platform_region
  environment_namespace           = local.environment_vars.locals.environment_namespace
  account_id                      = local.global_vars.locals.account_id

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
  )
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` command that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../components//eks_fargate"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_version = "1.21"
  environment_domain = local.environment_domain
  environment_namespace = local.environment_namespace

  # Subnets
  subnet_ids = dependency.vpc.outputs.private_subnets
  private_subnets = dependency.vpc.outputs.private_subnets
  public_subnets = dependency.vpc.outputs.public_subnets
  vpc_id  = dependency.vpc.outputs.vpc_id

  #worker group
  worker_group_asg_max_size  = 5
  worker_group_asg_min_size  = 1
  worker_group_instance_type = "t2.large"

  
  tags = local.tags
}

