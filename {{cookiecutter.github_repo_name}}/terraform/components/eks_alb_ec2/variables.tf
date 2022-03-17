#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
variable "vpc_id" {
  description = "ID of  the VPC where to create security groups"
  type        = string
  default     = null
}

variable "environment_domain" {
  type = string
}

variable "environment_namespace" {
  type = string
}

variable "root_domain" {
  description = "Root domain (route53 zone) for the default cluster ingress."
  type        = string
}

variable "subdomains" {
  description = "Base domain (route53 zone) for the default cluster ingress"
  type        = list(string)
}

variable "aws_region" {
  description = "the AWS region in which the S3 bucket was created"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the EKS cluster (ENIs) will be provisioned along with the nodes/node groups. Node groups can be deployed within a different set of subnet IDs from within the node group configuration"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs where the EKS cluster (ENIs) will be provisioned along with the nodes/node groups. Node groups can be deployed within a different set of subnet IDs from within the node group configuration"
  type        = list(string)
  default     = []
}

variable "eks_worker_group_desired_size" {
  type = number
}

variable "eks_worker_group_min_size" {
  type = number
}

variable "eks_worker_group_max_size" {
  type = number
}

variable "eks_worker_group_instance_type" {
  type = string
}

variable "tags" {
  description = "tags"
  type        = any
  default     = {}
}
