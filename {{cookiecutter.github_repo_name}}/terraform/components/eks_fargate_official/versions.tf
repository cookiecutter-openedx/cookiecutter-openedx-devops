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
    aws        = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    local      = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    random     = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    kubernetes = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    tls = ">= 2.2"
    cloudinit = ">= 2.0"
  }
}

