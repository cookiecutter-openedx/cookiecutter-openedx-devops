#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#------------------------------------------------------------------------------
variable "environment_domain" {
  type = string
}

variable "environment_subdomain" {
  type = string
}

variable "services_subdomain" {
  type = string
}
variable "environment_namespace" {
  description = "kubernetes namespace where to place resources"
  type        = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}

variable "shared_resource_namespace" {
  type = string
}
