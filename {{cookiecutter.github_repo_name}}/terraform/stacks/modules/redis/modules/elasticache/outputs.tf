output "configuration_endpoint_address" {
  description = "The configuration endpoint address to allow host discovery."
  value       = aws_elasticache_replication_group.this.configuration_endpoint_address
}

output "primary_endpoint_address" {
  description = "The address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "member_clusters" {
  description = "The identifiers of all the nodes that are part of this replication group."
  value       = aws_elasticache_replication_group.this.member_clusters
}

output "auth_token" {
  description = "The password used to access the Redis protected server."
  value       = aws_elasticache_replication_group.this.auth_token
  sensitive   = true
}
