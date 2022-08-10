#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    local = {
      source  = "hashicorp/local"
      version = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    }
  }
}
