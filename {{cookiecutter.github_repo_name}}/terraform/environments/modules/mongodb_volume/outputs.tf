#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: module outputs
#------------------------------------------------------------------------------

output "mongodb_volume_id" {
  description = "The id of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.id
}

output "mongodb_volume_arn" {
  description = "The arn of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.arn
}

output "mongodb_volume_availability_zone" {
  description = "The availability zone in which the EC2 EBS volume was created"
  value       = aws_ebs_volume.mongodb.availability_zone
}

output "mongodb_volume_subnet_id" {
  description = "The availability zone index in which the EC2 EBS volume was created"
  value       = data.aws_subnet.database_subnet.id
}

output "mongodb_volume_size" {
  description = "The allocated size of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.size
}

output "mongodb_volume_tags" {
  description = "The resource tags of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.tags
}

output "mongodb_volume_multi_attach_enabled" {
  description = "Boolean. whether mongodb_volume_multi_attach_enabled is enabled for the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.multi_attach_enabled
}

output "mongodb_volume_iops" {
  description = "The iops setting of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.iops
}

output "mongodb_volume_throughput" {
  description = "The throughput setting of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.throughput
}

output "mongodb_volume_type" {
  description = "The type of the EC2 EBS volume"
  value       = aws_ebs_volume.mongodb.type
}
