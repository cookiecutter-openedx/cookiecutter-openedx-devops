#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a non-public S3 Bucket to store data backups from any backend 
#        service.
#------------------------------------------------------------------------------ 
variable "bucket_name" {
  description = "Name of the Open edX S3 bucket"
  type        = string
  default     = null
}

variable "secret_name" {
  description = "name of the kubernetes secret where the value is stored"
  type        = string
}

variable "environment_namespace" {
  description = "kubernetes namespace where to place resources"
  type        = string
}


variable "environment_domain" {
  description = "base domain for service"
  type        = string
}

variable "environment" {
  description = "environment name"
  type        = string
}

variable "resource_name" {
  description = "the full environment-qualified name of this resource."
  type        = string
}


variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}
