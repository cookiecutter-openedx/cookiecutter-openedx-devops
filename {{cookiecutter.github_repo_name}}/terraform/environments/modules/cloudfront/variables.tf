#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#------------------------------------------------------------------------------
variable "environment_domain" {
  type = string
}

variable "environment_namespace" {
  type = string
}


variable "resource_name" {
  type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The region in which the origin S3 bucket was created."
  type        = string
}
