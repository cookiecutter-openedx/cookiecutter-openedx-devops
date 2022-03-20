#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------
variable "eks_cluster_version" {
  description = "Kubernetes cluster version."
  type        = string
  default     = "1.21"
}

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

# Variables for providing to module fixture codes


variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "subnets" {
  description = "The list of subnets to deploy an eks cluster"
  type        = list(string)
  default     = null
}

variable "enable_igw" {
  description = "Should be true if you want to provision Internet Gateway for internet facing communication"
  type        = bool
  default     = true
}

variable "enable_ngw" {
  description = "Should be true if you want to provision NAT Gateway(s) across all of private networks"
  type        = bool
  default     = false
}

variable "single_ngw" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of private networks"
  type        = bool
  default     = false
}


variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

variable "managed_node_groups" {
  description = "Amazon managed node groups definition"
  default     = []
}

variable "fargate_profiles" {
  description = "Amazon Fargate for EKS profiles"
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "eks"
}
