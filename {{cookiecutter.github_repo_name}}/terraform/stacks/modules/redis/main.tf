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
resource "aws_security_group" "redis" {
  description = "openedx_devops: Redis"
  name_prefix = local.name
  vpc_id      = var.vpc_id

  ingress {
    description = "openedx_devops: Redis access from within VPC"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }
  egress {
    description      = "openedx_devops: Redis out to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}


module "redis" {
  source = "./modules/elasticache"

  description                = local.name
  create_random_auth_token   = var.create_random_auth_token
  subnet_ids                 = var.subnet_ids
  engine                     = var.engine
  engine_version             = var.engine_version
  num_cache_clusters         = var.num_cache_clusters
  port                       = var.port
  vpc_security_group_ids     = [aws_security_group.redis.id]
  transit_encryption_enabled = var.transit_encryption_enabled
  family                     = var.family
  node_type                  = var.node_type
  tags                       = var.tags
}
