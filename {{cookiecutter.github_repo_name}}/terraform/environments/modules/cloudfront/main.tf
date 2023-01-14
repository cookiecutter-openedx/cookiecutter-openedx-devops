#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage:
# create one Cloudfront distribution for the environment, plus one more
# for each subdomain.
#
# the origin of the Cloudfront distribution will be an S3 bucket named
# of the form [environment]-[platform_name]-[platform_region]-storage
#
#------------------------------------------------------------------------------

locals {
  s3_bucket_name   = var.resource_name
  s3_bucket_domain = "${local.s3_bucket_name}.s3.${var.aws_region}.amazonaws.com"
  cdn_name         = "cdn.${var.environment_domain}"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}


data "aws_route53_zone" "environment_domain" {
  name = var.environment_domain

  tags = {
    "cookiecutter/environment_namespace" = var.environment_namespace
  }
}


# see eks_ec2/acm.tf or eks_fargate/acm.tf for creation of this certificate
# as well as the definition for the provider "aws.us-east-1"
data "aws_acm_certificate" "environment_domain" {
  domain   = var.environment_domain
  statuses = ["ISSUED"]
  provider = aws.us-east-1
  {% if cookiecutter.global_aws_region != "us-east-1" -%}
  depends_on = [module.acm_environment_domain]
  {% endif %}
}

data "aws_s3_bucket" "environment_domain" {
  bucket = local.s3_bucket_name
}

# see ./route53.tf for creation of data.aws_route53_zone.environment_domain.id
resource "aws_route53_record" "cdn_environment_domain" {
  zone_id = data.aws_route53_zone.environment_domain.id
  name    = local.cdn_name
  type    = "A"

  alias {
    name                   = module.cdn_environment_domain.cloudfront_distribution_domain_name
    zone_id                = module.cdn_environment_domain.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }

}


module "cdn_environment_domain" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "{{cookiecutter.terraform_aws_modules_cloudfront}}"

  aliases = [local.cdn_name]

  comment             = "Open edX LMS CDN"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  origin = {
    s3_bucket = {
      domain_name = "${local.s3_bucket_domain}"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_bucket"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]
      compress        = true
      query_string    = true
    }
  ]

  viewer_certificate = {
    acm_certificate_arn = data.aws_acm_certificate.environment_domain.arn
    ssl_support_method  = "sni-only"
  }
}
