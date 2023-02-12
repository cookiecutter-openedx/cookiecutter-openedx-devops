#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2023
#
# usage: create a Varnish cluster
#------------------------------------------------------------------------------
output "helm_release_id" {
  description = "The ID of the Varnish Operator"
  value       = helm_release.varnish_operator.id
}

output "helm_release_name" {
  description = "The name of the karpenter"
  value       = helm_release.varnish_operator.name
}

output "helm_release_namespace" {
  description = "The namespace of the karpenter"
  value       = helm_release.varnish_operator.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy karpenter"
  value       = helm_release.varnish_operator.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy karpenter"
  value       = helm_release.varnish_operator.repository
}
