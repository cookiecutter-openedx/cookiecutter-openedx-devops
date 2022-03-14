#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------ 
terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws        = "{{ cookiecutter.terraform_hashicorp_aws_version }}"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
  }
}

