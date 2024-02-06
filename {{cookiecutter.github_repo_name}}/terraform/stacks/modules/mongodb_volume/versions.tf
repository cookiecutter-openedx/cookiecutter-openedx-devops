#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: terraform library dependencies
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "{{cookiecutter.terraform_provider_hashicorp_local_version}}"
    }
    random = {
      source  = "hashicorp/random"
      version = "{{cookiecutter.terraform_provider_hashicorp_random_version}}"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "{{cookiecutter.terraform_provider_hashicorp_aws_version}}"
    }
  }
}
