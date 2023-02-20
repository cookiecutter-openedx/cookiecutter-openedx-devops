#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
variable "dashboard_namespace" {
    type = string
}

variable "dashboard_account_name" {
  type = string
}

variable "stack_namespace" {
    type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}
