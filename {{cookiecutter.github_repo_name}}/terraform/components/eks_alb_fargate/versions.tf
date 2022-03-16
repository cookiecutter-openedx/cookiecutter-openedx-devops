#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
terraform {
  # tflint-ignore
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    # tflint-ignore
    aws = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    # tflint-ignore
    kubernetes = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
  }
}
