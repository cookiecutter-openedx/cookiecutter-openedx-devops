#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: metrics-server module outputs
#------------------------------------------------------------------------------

output "helm_release_id" {
  description = "The ID of the metrics-server"
  value       = helm_release.metrics_server.id
}

output "helm_release_name" {
  description = "The name of the metrics-server"
  value       = helm_release.metrics_server.name
}

output "helm_release_namespace" {
  description = "The namespace of the metrics-server"
  value       = helm_release.metrics_server.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy metrics-server"
  value       = helm_release.metrics_server.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy metrics-server"
  value       = helm_release.metrics_server.repository
}
