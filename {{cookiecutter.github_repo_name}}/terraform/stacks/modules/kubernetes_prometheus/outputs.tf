#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: prometheus module outputs
#------------------------------------------------------------------------------

output "helm_release_id" {
  description = "The ID of the prometheus"
  value       = helm_release.prometheus.id
}

output "helm_release_name" {
  description = "The name of the prometheus"
  value       = helm_release.prometheus.name
}

output "helm_release_namespace" {
  description = "The namespace of the prometheus"
  value       = helm_release.prometheus.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy prometheus"
  value       = helm_release.prometheus.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy prometheus"
  value       = helm_release.prometheus.repository
}
