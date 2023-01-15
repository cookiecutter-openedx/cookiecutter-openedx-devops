#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------


output "helm_release__id" {
  description = "the ID of the ingress controller"
  value       = helm_release.ingress_nginx_controller.id
}


output "helm_release__chart" {
  description = "the helm chart used to deploy the ingress controller"
  value       = helm_release.ingress_nginx_controller.chart
}

output "helm_release_name" {
  description = "the name of the ingress controller"
  value       = helm_release.ingress_nginx_controller.name
}

output "helm_release_namespace" {
  description = "the namespace in which the ingress controller is deployed"
  value       = helm_release.ingress_nginx_controller.namespace
}

output "helm_release_repository" {
  description = "the helm chart repository used to deploy the ingress controller"
  value       = helm_release.ingress_nginx_controller.repository
}
