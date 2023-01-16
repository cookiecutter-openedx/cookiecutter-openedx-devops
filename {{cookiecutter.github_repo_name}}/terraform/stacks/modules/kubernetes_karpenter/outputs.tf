#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: Karpenter module outputs
#------------------------------------------------------------------------------
output "helm_release_id" {
  description = "The ID of the karpenter"
  value       = helm_release.karpenter.id
}

output "helm_release_name" {
  description = "The name of the karpenter"
  value       = helm_release.karpenter.name
}

output "helm_release_namespace" {
  description = "The namespace of the karpenter"
  value       = helm_release.karpenter.namespace
}

output "helm_release_chart" {
  description = "The chart used to deploy karpenter"
  value       = helm_release.karpenter.chart
}

output "helm_release_repository" {
  description = "The repository used to deploy karpenter"
  value       = helm_release.karpenter.repository
}


output "irsa_role_oidc_provider_arn" {
  description = "the OIDC provider ARN "
  value       = var.oidc_provider_arn
}

output "karpenter_iam_instance_profile_id" {
  description = "Karpetner IAM instance profile ID"
  value       = aws_iam_instance_profile.karpenter.id
}

output "karpenter_iam_instance_profile_name" {
  description = "Karpetner IAM instance profile name"
  value       = aws_iam_instance_profile.karpenter.name
}

output "karpenter_iam_instance_profile_role" {
  description = "Karpetner IAM instance profile role"
  value       = aws_iam_instance_profile.karpenter.role
}

output "aws_iam_role_ec2_spot_fleet_tagging_role_id" {
  description = "IAM role for EC2 spot fleet tagging role id"
  value       = aws_iam_role.ec2_spot_fleet_tagging_role.id
}

output "aws_iam_role_ec2_spot_fleet_tagging_role_name" {
  description = "IAM role for EC2 spot fleet tagging role name"
  value       = aws_iam_role.ec2_spot_fleet_tagging_role.name
}

output "aws_iam_role_policy_attachment_ec2_spot_fleet_tagging_id" {
  description = "IAM role policy attachment for EC2 spot fleet tagging role id"
  value       = aws_iam_role_policy_attachment.ec2_spot_fleet_tagging.id
}

output "aws_iam_role_policy_attachment_ec2_spot_fleet_tagging_policy_arn" {
  description = "IAM role policy attachment for EC2 spot fleet tagging role ARN"
  value       = aws_iam_role_policy_attachment.ec2_spot_fleet_tagging.policy_arn
}

output "aws_iam_role_policy_attachment_ec2_spot_fleet_tagging_role" {
  description = "IAM role policy attachment for EC2 spot fleet tagging role"
  value       = aws_iam_role_policy_attachment.ec2_spot_fleet_tagging.role
}
