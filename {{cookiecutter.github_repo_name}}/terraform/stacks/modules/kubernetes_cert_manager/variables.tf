#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

variable "namespace" {
  type = string
}

variable "cert_manager_namespace" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "services_subdomain" {
  type = string
}
