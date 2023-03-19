#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Mar-2022
#
# usage: build an EKS with EC2 worker nodes and ALB
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars    = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars   = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  env                             = local.stack_vars.locals.stack
  namespace                       = local.stack_vars.locals.stack_namespace
  root_domain                     = local.global_vars.locals.root_domain
  platform_name                   = local.global_vars.locals.platform_name
  platform_region                 = local.global_vars.locals.platform_region
  account_id                      = local.global_vars.locals.account_id
  aws_region                      = local.global_vars.locals.aws_region
  shared_resource_identifier      = local.global_vars.locals.shared_resource_identifier
  kubernetes_version              = local.stack_vars.locals.kubernetes_version
  eks_create_kms_key              = local.stack_vars.locals.eks_create_kms_key
  eks_hosting_group_instance_type = local.stack_vars.locals.eks_hosting_group_instance_type
  eks_hosting_group_min_size      = local.stack_vars.locals.eks_hosting_group_min_size
  eks_hosting_group_max_size      = local.stack_vars.locals.eks_hosting_group_max_size
  eks_hosting_group_desired_size  = local.stack_vars.locals.eks_hosting_group_desired_size
  eks_service_group_instance_type = local.stack_vars.locals.eks_service_group_instance_type
  eks_service_group_min_size      = local.stack_vars.locals.eks_service_group_min_size
  eks_service_group_max_size      =  local.stack_vars.locals.eks_service_group_max_size
  eks_service_group_desired_size  =  local.stack_vars.locals.eks_service_group_desired_size
  bastion_iam_arn                 = "arn:aws:iam::${local.account_id}:user/system/bastion-user/${local.namespace}-bastion"
  bastion_iam_username            = "${local.namespace}-bastion"

  tags = merge(
    local.stack_vars.locals.tags,
    local.global_vars.locals.tags,
    { "cookiecutter/name" = "${local.namespace}-eks" }
  )
}

dependency "vpc" {
  config_path = "../vpc"

  # Configure mock outputs for the `validate` and `init` commands that are returned when there are no outputs available (e.g the
  # module hasn't been applied yet.
  mock_outputs_allowed_terraform_commands = ["init", "validate", "destroy"]
  mock_outputs = {
    vpc_id           = "fake-vpc-id"
    public_subnets   = ["fake-public-subnet-01", "fake-public-subnet-02"]
    private_subnets  = ["fake-private-subnet-01", "fake-private-subnet-02"]
    database_subnets = ["fake-database-subnet-01", "fake-database-subnet-02"]
  }

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//kubernetes"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  account_id                      = local.account_id
  shared_resource_identifier      = local.shared_resource_identifier
  aws_region                      = local.aws_region
  root_domain                     = local.root_domain
  namespace                       = local.namespace
  private_subnet_ids              = dependency.vpc.outputs.private_subnets
  public_subnet_ids               = dependency.vpc.outputs.public_subnets
  vpc_id                          = dependency.vpc.outputs.vpc_id
  kubernetes_cluster_version      = local.kubernetes_version
  eks_create_kms_key              = local.eks_create_kms_key
  eks_hosting_group_instance_type = local.eks_hosting_group_instance_type
  eks_hosting_group_min_size      = local.eks_hosting_group_min_size
  eks_hosting_group_max_size      = local.eks_hosting_group_max_size
  eks_hosting_group_desired_size  = local.eks_hosting_group_desired_size
  eks_service_group_instance_type = local.eks_service_group_instance_type
  eks_service_group_min_size      = local.eks_service_group_min_size
  eks_service_group_max_size      = local.eks_service_group_max_size
  eks_service_group_desired_size  = local.eks_service_group_desired_size
  bastion_iam_arn                 = local.bastion_iam_arn
  tags                            = local.tags

  map_roles = []
  kms_key_owners = [
    "${local.bastion_iam_arn}",
    # -------------------------------------------------------------------------
    # ADD MORE CLUSTER ADMIN USER IAM ACCOUNTS TO THE AWS KMS KEY OWNER LIST:
    # -------------------------------------------------------------------------
    #"arn:aws:iam::${local.account_id}:user/mcdaniel",
    #"arn:aws:iam::${local.account_id}:user/bob_marley",
  ]
  map_users = [
    {
      userarn  = local.bastion_iam_arn
      username = local.bastion_iam_username
      groups   = ["system:masters"]
    },
    # -------------------------------------------------------------------------
    # ADD MORE CLUSTER ADMIN USER IAM ACCOUNTS HERE:
    # -------------------------------------------------------------------------
    #{
    #  userarn  = "arn:aws:iam::${local.account_id}:user/mcdaniel"
    #  username = "mcdaniel"
    #  groups   = ["system:masters"]
    #},
    #{
    #  userarn  = "arn:aws:iam::${local.account_id}:user/bob_marley"
    #  username = "bob_marley"
    #  groups   = ["system:masters"]
    #},
  ]

}
