#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: VPA module outputs
#------------------------------------------------------------------------------

output "helm_release_id" {
  description = "The ID of the VPA"
  value       = helm_release.vpa.id
}

output "helm_release_name" {
  description = "The name of the VPA"
  value       = helm_release.vpa.name
}

output "helm_release_namespace" {
  description = "The namespace of the VPA"
  value       = helm_release.vpa.namespace
}

output "helm_release_chart" {
  description = "The helm chart used to deploy VPA"
  value       = helm_release.vpa.chart
}

output "helm_release_repository" {
  description = "The helm chart repository used to deploy VPA"
  value       = helm_release.vpa.repository
}
