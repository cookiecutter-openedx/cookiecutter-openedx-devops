locals {
  name        = var.name
  description = coalesce(var.description, format("%s parameter group", var.name))
}

resource "aws_elasticache_parameter_group" "this" {
  count = var.create ? 1 : 0

  name        = local.name
  description = local.description
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
