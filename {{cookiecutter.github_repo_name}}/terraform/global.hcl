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
  platform_name              = "{{ cookiecutter.global_platform_name }}"
  platform_region            = "{{ cookiecutter.global_platform_region }}"
  shared_resource_identifier = "{{ cookiecutter.global_platform_shared_resource_identifier }}"
  shared_resource_namespace  = "{{ cookiecutter.global_platform_name }}-{{ cookiecutter.global_platform_region }}-{{ cookiecutter.global_platform_shared_resource_identifier }}"
  root_domain                = "{{ cookiecutter.global_root_domain }}"
  services_subdomain         = "{{ cookiecutter.global_services_subdomain }}.{{ cookiecutter.global_root_domain }}"
  aws_region                 = "{{ cookiecutter.global_aws_region }}"
  account_id                 = "{{ cookiecutter.global_account_id }}"

  tags = {
    "cookiecutter/platform_name"                = local.platform_name
    "cookiecutter/platform_region"              = local.platform_region
    "cookiecutter/shared_resource_identifier"   = local.shared_resource_identifier
    "cookiecutter/root_domain"                  = local.root_domain
    "cookiecutter/services_subdomain"           = local.services_subdomain
    "cookiecutter/terraform"                    = "true"
  }

}

inputs = {
  platform_name    = local.platform_name
  platform_region  = local.platform_region
  aws_region       = local.aws_region
  account_id       = local.account_id
  root_domain      = local.root_domain
}
