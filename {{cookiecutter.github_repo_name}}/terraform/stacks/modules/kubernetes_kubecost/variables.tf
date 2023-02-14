#-----------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: install Kubecost https://www.kubecost.com/
#-----------------------------------------------------------

# for providers.tf
variable "stack_namespace" {
  type = string
}

variable "services_subdomain" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
