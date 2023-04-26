variable "resource_name" {
  description = "The name of the shared RDS instance"
  type        = string
}

variable "environment_domain" {
  type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}

variable "environment_namespace" {
  type = string
}

variable "aws_region" {
  type = string
}
