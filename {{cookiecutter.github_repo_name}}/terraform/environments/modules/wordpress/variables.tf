#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: Wordpress module variable declarations
#------------------------------------------------------------------------------
variable "root_domain" {
  type = string
}

variable "shared_resource_namespace" {
  type = string
}

variable "wordpressConfig" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}

variable "aws_region" {
  type = string
}
