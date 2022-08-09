#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------
variable "shared_resource_identifier" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "namespace" {
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

variable "enable_irsa" {
  type    = bool
  default = true
}

variable "kubernetes_cluster_version" {
  type = string
}

variable "eks_worker_group_min_size" {
  type = number
}

variable "eks_worker_group_max_size" {
  type = number
}

variable "eks_karpenter_group_instance_type" {
  type = string
}

variable "eks_karpenter_group_min_size" {
  type = number
}

variable "eks_karpenter_group_max_size" {
  type = number
}

variable "eks_karpenter_group_desired_size" {
  type = number
}

variable "eks_worker_group_desired_size" {
  type = number
}

variable "eks_worker_group_instance_type" {
  type = string
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
