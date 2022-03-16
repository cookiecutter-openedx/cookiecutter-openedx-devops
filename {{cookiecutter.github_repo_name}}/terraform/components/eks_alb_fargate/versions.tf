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
    aws        = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    kubernetes = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
  }
}
