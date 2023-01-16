#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: MongoDB server module outputs
#------------------------------------------------------------------------------

output "mongodb_internal_ip" {
  description = "The internal ip address of the EC2 instance hosting MongoDB"
  value       = aws_instance.mongodb.private_ip
}


output "kubernetes_secret_mongodb_admin_name" {
  description = "The name of the k8s secret for the MongoDB admin user credentials"
  value       = kubernetes_secret.mongodb_admin.metadata[0].name
}

output "kubernetes_secret_mongodb_admin_namespace" {
  description = "The namespace of the k8s secret for the MongoDB admin user credentials"
  value       = kubernetes_secret.mongodb_admin.metadata[0].namespace
}

output "mongodb_hostname" {
  description = "The MongoDB host subdomain"
  value       = local.host_name
}

output "mongodb_subnet_id" {
  description = "the VPC subnet in which this instance was created"
  value       = aws_instance.mongodb.subnet_id
}

output "mongodb_ami" {
  description = "the Ubuntu Amazon Machine Image for this instance"
  value       = aws_instance.mongodb.ami
}

output "mongodb_subnet_ssh_keyname" {
  description = "the name of the ssh keypair assigned to this instance"
  value       = aws_instance.mongodb.key_name
}
