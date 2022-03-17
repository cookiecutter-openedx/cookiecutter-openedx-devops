#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Aug-2021
#
# usage: create a VPC to contain all Open edX backend resources.
#------------------------------------------------------------------------------

#   un-comment this if the root_domain is managed in route53
# -----------------------------------------------------------------------------
data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}


# -----------------------------------------------------------------------------
data "aws_route53_zone" "environment" {
  name = var.environment_domain
}
