#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#------------------------------------------------------------------------------
variable "storage_encrypted" {
  type        = bool
  default     = false
  description = "Specifies whether the DB cluster is encrypted. "
}
variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. "
}
variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier."
}
variable "preferred_maintenance_window" {
  type        = string
  default     = ""
  description = "The weekly time range during which system maintenance can occur, in (UTC) e.g., wed:04:00-wed:04:30"
}
variable "preferred_backup_window" {
  type    = string
  default = "The daily time range during which automated backups are created if automated backups are enabled using the BackupRetentionPeriod parameter.Time in UTC Default: A 30-minute window selected at random from an 8-hour block of time per regionE.g., 04:00-09:00"
}


variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}


variable "vpc_cidr_block" {
  type    = string
  default = "CIDR for the VPC. example: 192.168.0.0/20"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  description = ""
}

variable "cluster_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `master.var.name`"
  default     = ""
}
variable "reader_dns_name" {
  type        = string
  description = "Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `replicas.var.name`"
  default     = ""
}

variable "db_port" {
  type        = number
  default     = 27017
  description = "DocumentDB port"
}

variable "master_username" {
  type        = string
  default     = "admin1"
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "master_password" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints"
}

variable "engine" {
  type        = string
  default     = "docdb"
  description = "The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`"
}

variable "engine_version" {
  type        = string
  description = "The version number of the database engine to use"
}

variable "region" {
  type        = string
  description = "AWS Region for S3 bucket"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  type        = list(string)
  default     = []
}

variable "zone_id" {
  type        = string
  default     = ""
  description = "Route53 parent zone ID for the environment DNS records"
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of existing Security Groups to be allowed to connect to the DocumentDB cluster"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the DocumentDB cluster"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs"
}

variable "cluster_size" {
  type        = number
  default     = 1
  description = "Number of DB instances to create in the cluster"
}

variable "namespace" {
  description = ""
  type        = string
}
variable "name" {
  description = ""
  type        = string
}
variable "delimiter" {
  description = ""
  type        = string
}
variable "enabled" {
  description = ""
  type        = bool
}
variable "environment" {
  description = ""
  type        = string
}
variable "id_length_limit" {
  description = ""
  type        = number
}
variable "label_key_case" {
  description = ""
  type        = string
}
variable "label_order" {
  description = ""
  type        = list(string)
}
variable "label_value_case" {
  description = ""
  type        = string
}
variable "regex_replace_chars" {
  description = ""
  type        = string
}
variable "stage" {
  description = ""
  type        = string
}
variable "subnet_ids" {
  description = ""
  type        = list(string)
}
variable "tenant" {
  description = ""
  type        = string
}
variable "vpc_id" {
  description = ""
  type        = string
}
variable "deletion_protection" {
  description = ""
  type        = bool
}

variable "retention_period" {
  description = ""
  type        = string
}
variable "tags" {
  description = ""
  type        = map(string)
  default     = {}
}

variable "environment_namespace" {
  description = ""
  type        = string
}
variable "environment_domain" {
  description = ""
  type        = string
}

variable "resource_name" {
  type    = string
  default = ""
}
