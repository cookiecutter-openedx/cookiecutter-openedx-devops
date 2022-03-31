locals {
  auth_token                    = var.create_elasticache_instance && var.create_random_auth_token ? random_id.auth_token[0].hex : var.auth_token
  elasticache_subnet_group_name = coalesce(var.elasticache_subnet_group_name, module.elasticache_subnet_group.db_subnet_group_id)
  parameter_group_name_id       = var.create_elasticache_parameter_group ? module.elasticache_parameter_group.elasticache_parameter_group_id : var.parameter_group_name

  replication_group_id = random_string.id.result
  description          = "elasticache-${random_string.id.result}"
}

# Random string to use as auth token
resource "random_id" "auth_token" {
  count       = var.create_elasticache_instance && var.create_random_auth_token ? 1 : 0
  byte_length = 32
}

resource "random_string" "id" {
  lower   = true
  special = false
  number  = false
  length  = 8
}

module "elasticache_subnet_group" {
  source = "./modules/elasticache_subnet_group"

  name        = coalesce(var.elasticache_subnet_group_name, local.replication_group_id)
  description = var.elasticache_subnet_group_description
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, var.elasticache_subnet_group_tags)
}

module "elasticache_parameter_group" {
  source = "./modules/elasticache_parameter_group"

  name        = coalesce(var.parameter_group_name, local.replication_group_id)
  description = var.parameter_group_description
  family      = var.family
  parameters  = var.parameters

  tags = merge(var.tags, var.elasticache_parameter_group_tags)
}
#checkov:skip=CKV_AWS_31:Ensure all data stored in the Elasticache Replication Group is securely encrypted at transit and has auth token

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = local.replication_group_id
  description                = var.description
  engine                     = var.engine
  engine_version             = var.engine_version
  node_type                  = var.node_type
  num_cache_clusters         = var.num_cache_clusters
  port                       = var.port
  subnet_group_name          = local.elasticache_subnet_group_name
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  auth_token                 = local.auth_token
  parameter_group_name       = local.parameter_group_name_id
  security_group_ids         = var.vpc_security_group_ids
}
