#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
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
      version = "~> {{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
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
