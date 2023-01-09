#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------


output "cert_manager_policy" {
  description = "the cert-manager IAM policy ARN"
  value       = aws_iam_policy.cert_manager_policy.arn
}
