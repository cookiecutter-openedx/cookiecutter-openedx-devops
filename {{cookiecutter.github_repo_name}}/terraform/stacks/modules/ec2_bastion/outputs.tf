#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2022
#
# usage: Bastion server module outputs
#------------------------------------------------------------------------------

output "bastion_internal_ip" {
  description = "The internal ip address of the EC2 instance hosting bastion"
  value       = aws_instance.bastion.private_ip
}


output "bastion_hostname" {
  description = "The bastion host subdomain"
  value       = local.hostname
}

output "bastion_subnet_id" {
  description = "the VPC subnet in which this instance was created"
  value       = aws_instance.bastion.subnet_id
}

output "bastion_ami" {
  description = "the Ubuntu Amazon Machine Image for this instance"
  value       = aws_instance.bastion.ami
}

output "bastion_subnet_ssh_keyname" {
  description = "the name of the ssh keypair assigned to this instance"
  value       = aws_instance.bastion.key_name
}
