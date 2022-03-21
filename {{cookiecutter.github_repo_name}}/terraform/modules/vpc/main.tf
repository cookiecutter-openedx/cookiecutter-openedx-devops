#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#        this VPC is configured to generally use all AWS defaults.
#        Thus, you should get the same configuration here that you'd
#        get by creating a new VPC from the AWS Console.
#
#        There are a LOT of options in this module.
#        see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#------------------------------------------------------------------------------

module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> 3"
  create_vpc             = true
  name                   = var.name
  cidr                   = var.cidr
  azs                    = var.azs
  public_subnets         = var.public_subnets
  private_subnets        = var.private_subnets
  database_subnets       = var.database_subnets
  elasticache_subnets    = var.elasticache_subnets
  enable_ipv6            = var.enable_ipv6
  enable_dns_hostnames   = var.enable_dns_hostnames
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  public_subnet_tags     = var.public_subnet_tags
  private_subnet_tags    = var.private_subnet_tags

  #----------------------------------------------------------------------------
  # Sometimes it is handy to have public access to RDS instances
  # (it is not recommended for production) by specifying these arguments:
  #----------------------------------------------------------------------------
  #create_database_subnet_group           = true
  #create_database_subnet_route_table     = true
  #create_database_internet_gateway_route = true
  #enable_dns_hostnames = true
  #enable_dns_support   = true

  #----------------------------------------------------------------------------
  # Optional Settings for Network Access Control Lists (ACL or NACL)
  # example: https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/examples/network-acls/main.tf
  #----------------------------------------------------------------------------
  #manage_default_network_acl = true
  #public_dedicated_network_acl = true
  #public_inbound_acl_rules =
  #public_outbound_acl_rules =

  tags = var.tags
}
