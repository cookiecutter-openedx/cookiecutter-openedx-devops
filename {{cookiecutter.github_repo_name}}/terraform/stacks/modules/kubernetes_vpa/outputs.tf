#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create an EKS cluster
#------------------------------------------------------------------------------

output "id" {
  description = "The ID of the VPA"
  value       = helm_release.vpa.id
}

output "name" {
  description = "The name of the VPA"
  value       = helm_release.vpa.name
}

output "namespace" {
  description = "The namespace of the VPA"
  value       = helm_release.vpa.namespace
}
