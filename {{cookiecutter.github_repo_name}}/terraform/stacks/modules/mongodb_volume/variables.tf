#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: module variable declarations.
#------------------------------------------------------------------------------

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + stack + resouce tags."
  type        = map(string)
  default     = {}
}


variable "subnet_ids" {
  type = list(string)
}
