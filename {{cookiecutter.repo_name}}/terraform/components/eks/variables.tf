#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------ 
variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "enable_irsa" {
  description = "Whether to create OpenID Connect Provider for EKS to enable IRSA"
  type        = bool
  default     = false
}


variable "environment_domain" {
  type        = string
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



variable "environment_namespace" {
  type        = string
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

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap. See examples/basic/variables.tf for example format."
  type        = list(string)
  default     = []
}

variable "root_domain" {
  description = "Root domain (route53 zone) for the default cluster ingress."
  type        = string
}

variable "subdomains" {
  description = "Base domain (route53 zone) for the default cluster ingress"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}


variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
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

variable "worker_group_instance_type" {
  description = "Instance type for the worker group"
  type        = string
  default     = null
}
