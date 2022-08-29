#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: aug-2022
#
# usage: create environment connection resources for remote MongoDB instance.
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25"
    }
  }
}
