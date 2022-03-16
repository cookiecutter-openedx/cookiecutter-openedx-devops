#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a Javascript Web Token (JWT) to be added
#        to the Open edX build configuration.
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
