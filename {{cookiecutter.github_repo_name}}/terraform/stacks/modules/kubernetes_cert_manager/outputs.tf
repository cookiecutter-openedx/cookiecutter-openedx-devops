#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: cert-manager module outputs
#------------------------------------------------------------------------------

output "cert_manager_policy_arn" {
  description = "the cert-manager IAM policy ARN"
  value       = aws_iam_policy.cert_manager_policy.arn
}

output "cert_manager_policy_id" {
  description = "the cert-manager IAM policy id"
  value       = aws_iam_policy.cert_manager_policy.id
}

output "cert_manager_policy_name" {
  description = "the cert-manager IAM policy name"
  value       = aws_iam_policy.cert_manager_policy.name
}

output "cert_manager_policy_policy_id" {
  description = "the cert-manager IAM policy policy_id"
  value       = aws_iam_policy.cert_manager_policy.policy_id
}


output "helm_release_id" {
  description = "The ID of the cert-manager"
  value       = helm_release.cert-manager.id
}

output "helm_release_name" {
  description = "The name of the cert-manager"
  value       = helm_release.cert-manager.name
}

output "helm_release_namespace" {
  description = "The namespace of the cert-manager"
  value       = helm_release.cert-manager.namespace
}

output "helm_release_chart" {
  description = "The helm chart used to deploy cert-manager"
  value       = helm_release.cert-manager.chart
}

output "helm_release_repository" {
  description = "The helm chart repository used to deploy cert-manager"
  value       = helm_release.cert-manager.repository
}
