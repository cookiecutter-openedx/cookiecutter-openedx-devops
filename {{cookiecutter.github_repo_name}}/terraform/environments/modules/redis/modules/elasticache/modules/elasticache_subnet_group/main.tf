locals {
  name        = var.name
  description = coalesce(var.description, format("%s subnet group", var.name))
}

resource "aws_elasticache_subnet_group" "this" {
  count = var.create ? 1 : 0

  name        = local.name
  description = local.description
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      "Name" = var.name
    },
  )
}
