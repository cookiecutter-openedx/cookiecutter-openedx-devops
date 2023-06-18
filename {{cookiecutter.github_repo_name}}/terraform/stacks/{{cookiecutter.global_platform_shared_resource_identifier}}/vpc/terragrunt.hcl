#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------
locals {
  # Automatically load stack-level variables
  stack_vars   = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  global_vars  = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  root_domain           = local.global_vars.locals.root_domain
  services_subdomain    = local.global_vars.locals.services_subdomain
  platform_name         = local.global_vars.locals.platform_name
  platform_region       = local.global_vars.locals.platform_region
  aws_region            = local.global_vars.locals.aws_region
  stack_namespace       = local.stack_vars.locals.stack_namespace
  stack                 = local.stack_vars.locals.stack
  namespace             = local.stack_vars.locals.stack_namespace
  resource_name         = local.stack_vars.locals.stack_namespace

  tags = merge(
    local.stack_vars.locals.tags,
    {}
  )
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.

terraform {
  source = "../../modules//vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  root_domain           = local.root_domain
  services_subdomain    = local.services_subdomain
  aws_region            = local.aws_region
  namespace             = local.namespace
  name                  = "${local.resource_name}"
  cidr                  = "192.168.0.0/20"
  azs                   = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]

  public_subnets      = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  private_subnets     = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
  database_subnets    = ["192.168.8.0/24", "192.168.9.0/24"]
  elasticache_subnets = ["192.168.10.0/24", "192.168.11.0/24"]

  enable_ipv6          = false
  enable_dns_hostnames = true


  # NAT Gateway configuration
  # see: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
  #      https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html
  #
  # Each NAT Gateway operates within a designated AZ and is built with redundancy in that zone only.
  # As a result, if the NAT Gateway or AZ experiences failure, resources
  # utilizing that NAT Gateway in other AZ(s) also get impacted. Additionally,
  # routing traffic from one AZ to a NAT Gateway in a different AZ incurs
  # additional inter-AZ data transfer charges. We recommend choosing a
  # maintenance window for architecture changes in your Amazon VPC.
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false

  # a bit of foreshadowing:
  # AWS EKS uses tags for identifying resources which it interacts.
  # here we are tagging the public and private subnets with specially-named tags
  # that EKS uses to know where its public and internal load balancers should be placed.
  #
  # these tags are required, regardless of whether we're using EKS with EC2 worker nodes
  # or with a Fargate Compute Cluster.
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.namespace}" = "shared"
    "kubernetes.io/role/elb"                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.namespace}" = "shared"
    "kubernetes.io/role/internal-elb"          = "1"
    "karpenter.sh/discovery"                   = local.stack_namespace
  }

  tags = local.tags
}
