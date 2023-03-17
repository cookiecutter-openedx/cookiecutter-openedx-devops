#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
#
# usage: create an RDS MySQL instance.
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

variable "environment" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "db_prefix" {
  type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}
