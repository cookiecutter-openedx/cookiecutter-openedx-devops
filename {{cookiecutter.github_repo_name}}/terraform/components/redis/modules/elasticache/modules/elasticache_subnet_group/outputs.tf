output "db_subnet_group_id" {
  description = "The elasticache subnet group name"
  value       = element(concat(aws_elasticache_subnet_group.this.*.id, [""]), 0)
}
