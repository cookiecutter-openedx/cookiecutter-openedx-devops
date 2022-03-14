#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------ 
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "environment_namespace" {
  type        = string
}

variable "public_subnets" {
  description = "A list of subnets to place the EKS load balancer within."
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "aws_region" {
  description = "The region in which the EKS cluster will be created."
  type = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}


variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}


variable "tags" {
  description = "tags"
  type        = any
  default     = {}
}

variable "environment" {
  description = "environment name"
  type        = string
}

variable "worker_group_instance_type" {
  description = "Instance type for the worker group"
  type        = string
  default     = null
}
variable "worker_group_asg_max_size" {
  description = "Max number of nodes on the worker group ASG"
  type        = number
  default     = 1
}

variable "worker_group_asg_min_size" {
  description = "Min number of nodes on the worker group ASG"
  type        = number
  default     = 1
}

variable "eks_node_group_instance_type" {
  type        = "string"
  default     = null
}