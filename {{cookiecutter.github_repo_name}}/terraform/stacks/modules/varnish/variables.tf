#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create a Varnish cluster
#------------------------------------------------------------------------------

variable "stack_namespace" {
  type = string
}

variable "services_subdomain" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "shared_resource_namespace" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
