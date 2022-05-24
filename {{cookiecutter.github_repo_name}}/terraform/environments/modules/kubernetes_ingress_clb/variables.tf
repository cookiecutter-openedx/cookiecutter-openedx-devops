#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
variable "environment_domain" {
  type = string
}
variable "environment_namespace" {
  type = string
}

variable "shared_resource_namespace" {
  type = string
}

variable "namespace" {
  type = string
}

variable "root_domain" {
  description = "Root domain (route53 zone) for the default cluster ingress."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
