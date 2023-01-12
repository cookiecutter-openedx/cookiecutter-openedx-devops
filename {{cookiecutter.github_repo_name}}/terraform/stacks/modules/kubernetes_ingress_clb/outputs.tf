#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------


output "ingress_nginx_controller_id" {
  description = "the ID of the ingress controller"
  value       = helm_release.ingress_nginx_controller.id
}
