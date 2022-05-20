#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create global parameters, exposed to all
#        Terragrunt modules in this repository.
#------------------------------------------------------------------------------
locals {
  platform_name    = "mrionline"
  platform_region  = "global"
  shared_resource_identifier = "live"
  root_domain      = "mrionline.com"
  aws_region       = "us-east-2"
  account_id       = "621672204142"
  ec2_ssh_key_name = "mrionline-live"

  tags = {
    Platform        = local.platform_name
    Platform-Region = local.platform_region
    Terraform       = "true"
  }

}

inputs = {
  platform_name    = local.platform_name
  platform_region  = local.platform_region
  aws_region       = local.aws_region
  account_id       = local.account_id
  root_domain      = local.root_domain
  ec2_ssh_key_name = local.ec2_ssh_key_name
}
