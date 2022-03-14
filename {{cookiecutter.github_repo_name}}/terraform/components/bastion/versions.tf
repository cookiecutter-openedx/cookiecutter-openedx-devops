#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------ 
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    random = {
      source = "hashicorp/random"
      version = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    }
  }
}