#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.1"

  required_providers {
    local = "~> 2.2"
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.25"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12"
    }
  }
}
