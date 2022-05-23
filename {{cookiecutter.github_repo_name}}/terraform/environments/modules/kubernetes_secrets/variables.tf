#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#------------------------------------------------------------------------------
variable "namespace" {
  description = "kubernetes namespace where to place resources"
  type        = string
}

variable "resource_name" {
  description = "the full environment-qualified name of the EKS cluster"
  type        = string
}
