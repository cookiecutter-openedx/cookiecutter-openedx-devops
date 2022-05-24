variable "root_domain" {
  type = string
}

variable "environment_domain" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tags" {
  description = "collection of all tags to add to this resource. execting the combination of global + environment + resouce tags."
  type        = map(string)
  default     = {}
}
