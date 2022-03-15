#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster with application load balancer
#        that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------ 


resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "fargate"
  }
}
