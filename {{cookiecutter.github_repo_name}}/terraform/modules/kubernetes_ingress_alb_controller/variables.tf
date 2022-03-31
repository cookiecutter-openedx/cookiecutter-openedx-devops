#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
#------------------------------------------------------------------------------
variable "root_domain" {
  type = string
}

variable "environment_domain" {
  type = string
}

variable "subdomains" {
  type = list(string)
}

variable "environment_namespace" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
