#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

variable "root_domain" {
  type = string
}
variable "environment_domain" {
  type = string
}

variable "wordpress_domain" {
  type = string
}

variable "wordpress_namespace" {
  type = string
}
variable "environment_namespace" {
  type = string
}

variable "shared_resource_namespace" {
  type = string
}

variable "tags" {
}

variable "aws_region" {
  type = string
}
