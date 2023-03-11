#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
variable "root_domain" {
  type = string
}

variable "namespace" {
  type = string
}

variable "cert_manager_namespace" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "services_subdomain" {
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
