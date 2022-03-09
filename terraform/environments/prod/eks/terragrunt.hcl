#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
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
  cluster_name                    = local.environment_vars.locals.environment_namespace
  account_id                      = local.global_vars.locals.account_id
  eks_worker_group_instance_type  = local.environment_vars.locals.eks_worker_group_instance_type

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
  source = "../../../components//eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  cluster_name    = "${local.cluster_name}"
  cluster_version = "1.21"
  enable_irsa     = true

  # Subnets
  subnets = dependency.vpc.outputs.private_subnets
  vpc_id  = dependency.vpc.outputs.vpc_id

  #worker group
  worker_group_asg_max_size  = 5
  worker_group_asg_min_size  = 1
  worker_group_instance_type = local.eks_worker_group_instance_type

  environment_domain = local.environment_domain

  # TODO: Make this dynamic from list of users / ops user management
  map_users = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/ci"
      username = "ci"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${local.account_id}:user/mcdaniel"
      username = "mcdaniel"
      groups   = ["system:masters"]
    }
  ]

  tags = local.tags
}

