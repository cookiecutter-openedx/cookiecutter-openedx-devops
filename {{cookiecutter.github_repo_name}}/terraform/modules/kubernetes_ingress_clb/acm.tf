#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: Add tls certs to us-east-1 for Cloudfront distributions.
#
# we have to add these here, inside of eks because we
# need to iterate the subdomains, and this is only possible
# within the terragrunt module in which the subdomain
# resources are created.
#
# that is, the following line only works from
# inside eks:
#     aws_route53_zone.subdomain[count.index].name
#
# where aws_route53_zone was declared as a resource rather
# than as data
#------------------------------------------------------------------------------

# FIX NOTE: do we even need this for anything?

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
