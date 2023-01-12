#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a remote MongoDB server with access limited to the VPC.
#------------------------------------------------------------------------------

variable "platform_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "availability_zone" {
  type = string
}
variable "stack_namespace" {
  description = "the full stack-qualified name of this resource."
  type        = string
}

variable "resource_name" {
  type = string
}
variable "username" {
  description = "Username for the master DB user"
  type        = string
  default     = null
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "The VPC subnet ID to created the ec2 instance"
  type        = string
}


variable "vpc_id" {
  description = "ID of  the VPC where to create security groups"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = null
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = string
  default     = null
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + stack + resouce tags."
  type        = map(string)
  default     = {}
}

variable "services_subdomain" {
  type = string
}
