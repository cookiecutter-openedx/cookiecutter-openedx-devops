#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2022
#
# usage: create ssl/tls certificates in aws_region and us-east-1
#
#------------------------------------------------------------------------------

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
provider "aws" {
  alias  = "environment_region"
  region = var.aws_region
}


module "acm_subdomains" {
  source  = "terraform-aws-modules/acm/aws"
  version = "{{ cookiecutter.terraform_aws_modules_acm }}"

  providers = {
    aws = aws.us-east-1
  }

  count       = length(var.subdomains)
  domain_name = aws_route53_zone.subdomain[count.index].name
  zone_id     = aws_route53_zone.subdomain[count.index].id

  subject_alternative_names = [
    "*.${aws_route53_zone.subdomain[count.index].name}",
  ]

  wait_for_validation = true
  tags                = var.tags
}

module "acm_subdomains_environment_region" {
  source  = "terraform-aws-modules/acm/aws"
  version = "{{ cookiecutter.terraform_aws_modules_acm }}"

  providers = {
    aws = aws.environment_region
  }

  count       = length(var.subdomains)
  domain_name = aws_route53_zone.subdomain[count.index].name
  zone_id     = aws_route53_zone.subdomain[count.index].id

  subject_alternative_names = [
    "*.${aws_route53_zone.subdomain[count.index].name}",
  ]

  wait_for_validation = true
  tags                = var.tags
}
