#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    local = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    random = {
      source  = "hashicorp/random"
      version = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "{{ cookiecutter.terraform_provider_hashicorp_kubectl_version }}"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "{{ cookiecutter.terraform_provider_hashicorp_helm_version }}"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
    }
  }
}
