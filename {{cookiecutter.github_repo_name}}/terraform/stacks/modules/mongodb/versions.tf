#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a remote MongoDB server with access limited to the VPC.
#------------------------------------------------------------------------------
terraform {
  required_version = "~> 1.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
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
