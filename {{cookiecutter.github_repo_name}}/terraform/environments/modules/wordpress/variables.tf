#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

variable "environment_domain" {
  type = string
}

variable "wordpress_domain" {
  type = string
}
variable "environment_namespace" {
  type = string
}
