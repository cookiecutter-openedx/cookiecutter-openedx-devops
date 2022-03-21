#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an Application Load Balancer
#------------------------------------------------------------------------------
variable "subdomains" {
  type = list(string)
}

variable "environment_domain" {
  type = string
}

variable "root_domain" {
  description = "Root domain (route53 zone) for the default cluster ingress."
  type        = string
}

variable "environment_namespace" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "k8s_namespace" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
