#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Kubeapps module outputs
#------------------------------------------------------------------------------
output "helm_release_id" {
  description = "The ID of the kubeapps"
  value       = helm_release.kubeapps.id
}

output "helm_release_name" {
  description = "The name of the kubeapps"
  value       = helm_release.kubeapps.name
}

output "helm_release_namespace" {
  description = "The namespace of the kubeapps"
  value       = helm_release.kubeapps.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy kubeapps"
  value       = helm_release.kubeapps.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy kubeapps"
  value       = helm_release.kubeapps.repository
}
