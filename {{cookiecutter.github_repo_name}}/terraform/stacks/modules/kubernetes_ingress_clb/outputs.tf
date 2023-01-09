#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: build an EKS cluster load balancer
#------------------------------------------------------------------------------


output "cluster_arn" {
  description = "the AWS Route53 wildcard DNS record ID"
  value       = aws_route53_record.root_wildcard.id
}
