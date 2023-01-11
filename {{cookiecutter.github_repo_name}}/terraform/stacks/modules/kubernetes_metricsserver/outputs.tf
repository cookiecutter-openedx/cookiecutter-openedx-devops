#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

output "id" {
  description = "The ID of the metrics-server"
  value       = helm_release.metrics_server.id
}

output "name" {
  description = "The name of the metrics-server"
  value       = helm_release.metrics_server.name
}

output "namespace" {
  description = "The namespace of the metrics-server"
  value       = helm_release.metrics_server.namespace
}
