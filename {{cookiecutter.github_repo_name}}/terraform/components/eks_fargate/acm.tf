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

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "acm_root_domain" {
    source    = "terraform-aws-modules/acm/aws"
    version   = "~> 3.0"

    providers = {
      aws = aws.us-east-1
    }

    domain_name  = var.root_domain
    zone_id      = data.aws_route53_zone.root_domain.id

    subject_alternative_names = [
        "*.${var.root_domain}",
    ]

    wait_for_validation = true
    tags = var.tags
}

module "acm_environment_domain" {
    source    = "terraform-aws-modules/acm/aws"
    version   = "~> 3.0"

    providers = {
      aws = aws.us-east-1
    }

    domain_name  = var.environment_domain
    zone_id      = data.aws_route53_zone.environment_domain.id

    subject_alternative_names = [
        "*.${var.environment_domain}",
    ]

    wait_for_validation = true
    tags = var.tags
}

module "acm_subdomains" {
    source    = "terraform-aws-modules/acm/aws"
    version   = "~> 3.0"

    providers = {
      aws = aws.us-east-1
    }

    count        = length(var.subdomains)
    domain_name  = aws_route53_zone.subdomain[count.index].name
    zone_id      = aws_route53_zone.subdomain[count.index].id

    subject_alternative_names = [
        "*.${aws_route53_zone.subdomain[count.index].name}",
    ]

    wait_for_validation = true
    tags = var.tags
}


