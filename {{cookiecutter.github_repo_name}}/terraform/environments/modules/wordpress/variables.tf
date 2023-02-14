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

variable "phpmyadmin" {
  type    = string
  default = "N"
}

variable "resource_quota" {
  type    = string
  default = "Y"
}

variable "resource_quota_cpu" {
  type    = string
  default = "1"
}

variable "resource_quota_memory" {
  type    = string
  default = "1Gi"
}
