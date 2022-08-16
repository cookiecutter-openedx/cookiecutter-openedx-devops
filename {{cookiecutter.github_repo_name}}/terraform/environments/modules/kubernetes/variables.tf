#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

variable "resource_name" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "environment_namespace" {
  type = string
}
