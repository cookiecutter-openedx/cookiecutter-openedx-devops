#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws        = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    kubernetes = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    helm       = "{{ cookiecutter.terraform_provider_hashicorp_helm_version }}"
  }
}
