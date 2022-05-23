#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an ElastiCache Redis cache
#------------------------------------------------------------------------------
output "configuration_endpoint_address" {
  description = "The configuration endpoint address to allow host discovery."
  value       = module.redis.configuration_endpoint_address
}

output "primary_endpoint_address" {
  description = "The address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  value       = module.redis.primary_endpoint_address
}

output "member_clusters" {
  description = "The identifiers of all the nodes that are part of this replication group."
  value       = module.redis.member_clusters
}

output "auth_token" {
  description = "The password used to access the Redis protected server."
  value       = module.redis.auth_token
  sensitive   = true
}
