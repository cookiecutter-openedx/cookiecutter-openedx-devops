output "elasticache_parameter_group_id" {
  description = "The elasticache parameter group id"
  value       = element(concat(aws_elasticache_parameter_group.this.*.id, [""]), 0)
}
