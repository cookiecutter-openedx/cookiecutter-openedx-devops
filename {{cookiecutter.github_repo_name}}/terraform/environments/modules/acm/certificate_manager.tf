#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Apr-2022
#
# usage: Add DNS records and tls certs to stack aws_region for ELB.
# Also add certs to us-east-1 for Cloudfront distributions.
#------------------------------------------------------------------------------
provider "aws" {
  alias  = "environment_region"
  region = var.aws_region
}

data "aws_route53_zone" "root_domain" {
  name = var.root_domain
}

data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain
}


module "acm_root_domain_environment_region" {
  source  = "terraform-aws-modules/acm/aws"
  version = "{{ cookiecutter.terraform_aws_modules_acm }}"

  providers = {
    aws = aws.environment_region
  }

  domain_name = var.root_domain
  zone_id     = data.aws_route53_zone.root_domain.id

  subject_alternative_names = [
    "*.${var.root_domain}",
  ]

  wait_for_validation = true
  tags                = var.tags
}

module "acm_environment_environment_region" {
  source  = "terraform-aws-modules/acm/aws"
  version = "{{ cookiecutter.terraform_aws_modules_acm }}"

  providers = {
    aws = aws.environment_region
  }

  domain_name = var.environment_domain
  zone_id     = data.aws_route53_zone.environment_domain.id

  subject_alternative_names = [
    "*.${var.environment_domain}",
  ]

  wait_for_validation = true
  tags                = var.tags
}
