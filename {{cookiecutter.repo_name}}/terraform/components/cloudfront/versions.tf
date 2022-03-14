#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#------------------------------------------------------------------------------ 
terraform {
  required_version = ">= 1.1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "{{ cookiecutter.terraform_hashicorp_aws_version }}"
    }
  }
}