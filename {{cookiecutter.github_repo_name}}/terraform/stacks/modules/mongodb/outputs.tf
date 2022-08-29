#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: create a remote MongoDB server with access limited to the VPC.
#------------------------------------------------------------------------------

output "mongodb_internal_ip" {
  description = "The internal ip address of the EC2 instance hosting MongoDB"
  value       = aws_instance.mongodb.private_ip
}
