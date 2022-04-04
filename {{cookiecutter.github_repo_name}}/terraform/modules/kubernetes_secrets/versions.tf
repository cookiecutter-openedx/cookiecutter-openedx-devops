#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#------------------------------------------------------------------------------
terraform {
  required_version = "{{ cookiecutter.terraform_required_version }}"

  required_providers {
    aws        = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    local      = "{{ cookiecutter.terraform_provider_hashicorp_local_version }}"
    random     = "{{ cookiecutter.terraform_provider_hashicorp_random_version }}"
    kubernetes = "{{ cookiecutter.terraform_provider_kubernetes_version }}"
  }
}
