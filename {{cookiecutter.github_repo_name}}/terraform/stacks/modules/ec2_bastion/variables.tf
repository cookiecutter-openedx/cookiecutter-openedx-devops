#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: create an EC2 instance with ssh access and a DNS record.
#------------------------------------------------------------------------------

variable "instance_type" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "aws_region" {
  type = string
}
variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}
variable "availability_zone" {
  description = "AZ for the EC2 instance"
  type        = string
  default     = ""
}
variable "ingress_cidr_blocks" {
  description = "ingress_cidr_blocks"
  type        = list(any)
  default     = []
}
variable "security_group_name_prefix" {
  description = "security_group_name_prefix"
  type        = string
  default     = ""
}
variable "subnet_ids" {
  description = "subnet_ids"
  type        = list(any)
  default     = []
}
variable "tags" {
  description = "tags"
  type        = any
  default     = {}
}
variable "platform_name" {
  type = string
}
variable "platform_region" {
  type = string
}
variable "stack" {
  type = string
}

variable "resource_name" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "stack_namespace" {
  type = string
}
