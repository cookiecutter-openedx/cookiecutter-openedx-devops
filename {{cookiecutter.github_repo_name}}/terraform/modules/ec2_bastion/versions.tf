#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
