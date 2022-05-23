#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#------------------------------------------------------------------------------
variable "namespace" {
  description = "universal identifier for most resources"
  type        = string
}

variable "namespace" {
  description = "kubernetes namespace where to place resources"
  type        = string
}

variable "resource_name" {
  description = "the full stack-qualified name of this resource."
  type        = string
}


variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + stack + resouce tags."
  type        = map(string)
  default     = {}
}
