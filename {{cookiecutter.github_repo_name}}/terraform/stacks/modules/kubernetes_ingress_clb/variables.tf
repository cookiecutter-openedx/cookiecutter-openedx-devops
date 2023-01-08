#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------

variable "admin_domain" {
  type = string
}

variable "root_domain" {
  description = "Root domain (route53 zone) for the default cluster ingress."
  type        = string
}

variable "namespace" {
  type = string
}

variable "stack_namespace" {
  type = string
}
