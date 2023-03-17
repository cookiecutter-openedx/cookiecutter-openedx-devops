#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#------------------------------------------------------------------------------
variable "environment_namespace" {
  description = "kubernetes namespace where to place resources"
  type        = string
}

variable "resource_name" {
  description = "the full environment-qualified name of the EKS cluster"
  type        = string
}

variable "root_domain" {
  type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}
