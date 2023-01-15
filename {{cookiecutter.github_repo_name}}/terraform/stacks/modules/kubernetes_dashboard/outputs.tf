#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Kubernetes Dashboard module outputs
#------------------------------------------------------------------------------

output "helm_release_id" {
  description = "The ID of the kubernetes-dashboard"
  value       = helm_release.kubernetes-dashboard.id
}

output "helm_release_name" {
  description = "The name of the kubernetes-dashboard"
  value       = helm_release.kubernetes-dashboard.name
}

output "helm_release_namespace" {
  description = "The namespace of the kubernetes-dashboard"
  value       = helm_release.kubernetes-dashboard.namespace
}

output "helm_release_chart" {
  description = "The helm chart used to deploy kubernetes-dashboard"
  value       = helm_release.kubernetes-dashboard.chart
}

output "helm_release_repository" {
  description = "The helm chart repository used to deploy kubernetes-dashboard"
  value       = helm_release.kubernetes-dashboard.repository
}
