#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: kubecost module outputs
#------------------------------------------------------------------------------

output "helm_release_id" {
  description = "The ID of the kubecost"
  value       = helm_release.kubecost.id
}

output "helm_release_name" {
  description = "The name of the kubecost"
  value       = helm_release.kubecost.name
}

output "helm_release_namespace" {
  description = "The namespace of the kubecost"
  value       = helm_release.kubecost.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy kubecost"
  value       = helm_release.kubecost.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy kubecost"
  value       = helm_release.kubecost.repository
}
