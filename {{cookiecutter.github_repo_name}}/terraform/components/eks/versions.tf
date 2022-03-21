#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws   = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    local = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
  }
}
