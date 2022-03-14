#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
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
