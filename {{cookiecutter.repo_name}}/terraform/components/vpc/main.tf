#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------ 

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git//?ref=v3.0.0"

  name = var.name
  cidr = var.cidr

  azs                 = var.azs
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  database_subnets    = var.database_subnets
  elasticache_subnets = var.elasticache_subnets

  enable_ipv6          = var.enable_ipv6
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags

  tags = var.tags
}

