#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an AWS S3 bucket to offload Open edX file storage.
#------------------------------------------------------------------------------

module "openedx_storage" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> {{ cookiecutter.terraform_aws_modules_s3 }}"

  bucket                   = var.resource_name_storage
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  tags = merge(
    local.tags,
    {
      "cookiecutter/resource/source"  = "terraform-aws-modules/s3-bucket/aws"
      "cookiecutter/resource/version" = "{{ cookiecutter.terraform_aws_modules_s3 }}"
    }
  )

  # attach_policy = true
  # policy        = data.aws_iam_policy_document.bucket_policy.json

  cors_rule = [
    {
      allowed_methods = ["GET", "POST", "PUT", "HEAD"]
      allowed_origins = [
        "https://${var.environment_domain}",
        "https://apps.${var.environment_domain}",
        "https://discovery.${var.environment_domain}",
        "https://preview.${var.environment_domain}",
        "https://${var.environment_studio_domain}",

        "http://${var.environment_domain}",
        "http://apps.${var.environment_domain}",
        "http://discovery.${var.environment_domain}",
        "http://preview.${var.environment_domain}",
        "http://${var.environment_studio_domain}"
      ]
      allowed_headers = ["*"]
      expose_headers = [
        "Access-Control-Allow-Origin",
        "Access-Control-Allow-Method",
        "Access-Control-Allow-Header"
      ]
      max_age_seconds = 3000
    }
  ]
  versioning = {
    enabled = false
  }
}
