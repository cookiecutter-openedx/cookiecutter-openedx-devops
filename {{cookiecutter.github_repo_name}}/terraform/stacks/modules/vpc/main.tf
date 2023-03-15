#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: mar-2022
#
# usage: create a VPC to contain all Open edX backend resources.
#        this VPC is configured to generally use all AWS defaults.
#        Thus, you should get the same configuration here that you'd
#        get by creating a new VPC from the AWS Console.
#
#        There are a LOT of options in this module.
#        see https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#------------------------------------------------------------------------------
locals {
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/mysql"
    }
  )

}
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  version                = "~> {{ cookiecutter.terraform_aws_modules_vpc }}"
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

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/vpc/aws"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_vpc }}"
    }
  )
}

module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
