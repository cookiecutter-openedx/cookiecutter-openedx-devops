#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: aug-2022
#
# usage: create environment connection resources for remote MongoDB instance.
#------------------------------------------------------------------------------

variable "resource_name" {
  description = "The name of the shared RDS instance"
  type        = string
}

variable "shared_resource_namespace" {
  type = string
}

variable "environment_domain" {
  type = string
}

variable "environment_namespace" {
  type = string
}

variable "db_prefix" {
  type = string
}
