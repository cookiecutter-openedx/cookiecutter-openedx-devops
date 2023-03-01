#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
variable "stack_namespace" {
  type = string
}

variable "service_node_group_iam_role_name" {
  type = string
}

variable "service_node_group_iam_role_arn" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
