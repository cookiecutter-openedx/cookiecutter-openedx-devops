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

eks_node_group_instance_types
vpc_id
aws_region