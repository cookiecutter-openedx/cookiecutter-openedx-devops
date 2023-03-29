#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date:   apr-2023
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> {{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    local = {
      source  = "hashicorp/local"
      version = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    }
  }
}
