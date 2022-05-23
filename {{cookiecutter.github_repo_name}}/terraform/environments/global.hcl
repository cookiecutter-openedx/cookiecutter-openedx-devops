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
  platform_name    = "{{ cookiecutter.global_platform_name }}"
  platform_region  = "{{ cookiecutter.global_platform_region }}"
  root_domain      = "{{ cookiecutter.global_root_domain }}"
  aws_region       = "{{ cookiecutter.global_aws_region }}"
  account_id       = "{{ cookiecutter.global_account_id }}"

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
}
