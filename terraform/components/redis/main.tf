#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#
# FIX NOTE: get rid of module dependency
#------------------------------------------------------------------------------ 
locals {
  name = var.replication_group_description
}

################################################################################
# Supporting Resources
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name        = local.name
  description = "Allow access to MySQL"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Redis access from within VPC"
      cidr_blocks = join(",", var.ingress_cidr_blocks)
    },
  ]
  tags = var.tags
}


module "redis" {
  source = "./modules/elasticache"

  replication_group_description = var.replication_group_description
  create_random_auth_token      = var.create_random_auth_token

  # DB subnet group
  subnet_ids = var.subnet_ids

  engine                     = var.engine
  engine_version             = var.engine_version
  number_cache_clusters      = var.number_cache_clusters
  port                       = var.port
  vpc_security_group_ids     = [module.security_group.security_group_id]
  transit_encryption_enabled = var.transit_encryption_enabled


  # DB parameter group
  family    = var.family
  node_type = var.node_type
}

