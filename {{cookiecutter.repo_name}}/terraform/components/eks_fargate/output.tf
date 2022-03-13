#------------------------------------------------------------------------------ 
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: March-2022
#
# usage: build an EKS cluster load balancer that uses a Fargate Compute Cluster
#------------------------------------------------------------------------------ 
output "cluster_id" {
value  = aws_eks_cluster.eks_cluster.id
}

output "cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

data "kubernetes_ingress" "address" {
  metadata {
    name = "owncloud-lb"
    namespace = "fargate-node"
  }
}

output "database_endpoint" {
    value = "${data.aws_db_instance.database.address}"
}

output "server_dns" {
    value = "${data.kubernetes_ingress.address.load_balancer_ingress}"
}