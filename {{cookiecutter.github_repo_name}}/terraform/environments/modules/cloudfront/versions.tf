#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
  }
}
