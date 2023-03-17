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
  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source" = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/redis"
    }
  )

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

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "{{ cookiecutter.github_repo_name }}/terraform/stacks/modules/redis/modules/elasticache"
      "cookiecutter/resource/version" = "latest"
    }

  )
}

#------------------------------------------------------------------------------
#                        SUPPORTING RESOURCES
#------------------------------------------------------------------------------
resource "aws_security_group" "redis" {
  description = "cookiecutter: Redis"
  name_prefix = "${local.name}-redis"
  vpc_id      = var.vpc_id

  ingress {
    description = "cookiecutter: Redis access from within VPC"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }
  egress {
    description      = "cookiecutter: Redis out to anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "hashicorp/aws/aws_security_group"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_provider_hashicorp_aws_version }}"
    }

  )
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
