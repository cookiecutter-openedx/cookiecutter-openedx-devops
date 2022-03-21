#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an Application Load Balancer
#------------------------------------------------------------------------------
environment_namespace = local.environment_namespace
environment_domain    = local.environment_domain
aws_region            = local.aws_region
vpc_id                = dependency.vpc.outputs.vpc_id
k8s_namespace         = "ingress-alb"
tags                  = local.tags

variable "environment_domain" {
  type = string
}

variable "environment_namespace" {
  type = string
}


variable "k8s_namespace" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
