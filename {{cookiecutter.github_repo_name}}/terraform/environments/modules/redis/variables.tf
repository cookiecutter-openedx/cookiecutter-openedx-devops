#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#------------------------------------------------------------------------------
variable "environment_domain" {
  type = string
}

variable "shared_resource_namespace" {
  type = string
}
variable "create_elasticache_instance" {
  description = "Whether to create a cache instance"
  type        = bool
  default     = true
}

variable "replication_group_description" {
  description = "A user-created description for the replication group."
  type        = string
}

variable "node_type" {
  description = "The instance type of the ElastiCache instance"
  type        = string
}

variable "multi_az" {
  description = "Specifies if the ElastiCache cluster is multi-AZ"
  type        = bool
  default     = false
}

variable "num_cache_clusters" {
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2."
  type        = number
  default     = "2"
}

variable "engine" {
  description = "he name of the cache engine to be used for the clusters in this replication group. The only valid value is redis"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The engine version that your ElastiCache Cluster will use. This will differ between the use of 'redis' or 'memcached'. The default is '5.0.6' with redis being the assumed engine."
  type        = string
  default     = "6.x"
}

variable "port" {
  description = "The port on which the ElastiCache accepts connections"
  type        = string
}

variable "create_random_auth_token" {
  description = "Whether to create random password for RDS primary cluster"
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
  default     = null
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit."
  type        = bool
  default     = null
}

# ElastiCache subnet group
variable "create_elasticache_subnet_group" {
  description = "Whether to create a elasticache subnet group"
  type        = bool
  default     = true
}

variable "elasticache_subnet_group_name" {
  description = "Name of ElastiCache subnet group. ElastiCache instance will be created in the VPC associated with the ElastiCache subnet group. If unspecified, will be created in the default VPC"
  type        = string
  default     = null
}

variable "elasticache_subnet_group_use_name_prefix" {
  description = "Determines whether to use `subnet_group_name` as is or create a unique name beginning with the `subnet_group_name` as the prefix"
  type        = bool
  default     = true
}

variable "elasticache_subnet_group_description" {
  description = "Description of the ElastiCache subnet group to create"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  default     = []
}



variable "elasticache_instance_tags" {
  description = "Additional tags for the ElastiCache instance"
  type        = map(string)
  default     = {}
}

variable "elasticache_option_group_tags" {
  description = "Additional tags for the ElastiCache option group"
  type        = map(string)
  default     = {}
}

variable "elasticache_parameter_group_tags" {
  description = "Additional tags for the  ElastiCache parameter group"
  type        = map(string)
  default     = {}
}

variable "elasticache_subnet_group_tags" {
  description = "Additional tags for the ElastiCache subnet group"
  type        = map(string)
  default     = {}
}


# ElastiCache parameter group
variable "create_elasticache_parameter_group" {
  description = "Whether to create a database parameter group"
  type        = bool
  default     = true
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate with this cache cluster. Again this will differ between the use of 'redis' or 'memcached' and your engine version. The default is 'default.redis6.x'."
  type        = string
  default     = null
}

variable "parameter_group_description" {
  description = "Description of the ElastiCache parameter group to create"
  type        = string
  default     = ""
}

variable "family" {
  description = "The family of the ElastiCache parameter group"
  type        = string
  default     = ""
}

variable "parameters" {
  description = "A list of ElastiCache parameters (map) to apply"
  type        = list(map(string))
  default     = []
}

variable "vpc_id" {
  description = "ID of  the VPC where to create security groups"
  type        = string
  default     = null
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = []
}

variable "environment_namespace" {
  description = "kubernetes namespace where to place resources"
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
