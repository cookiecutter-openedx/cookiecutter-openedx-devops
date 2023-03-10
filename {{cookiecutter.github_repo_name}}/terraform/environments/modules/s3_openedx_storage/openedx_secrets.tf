#------------------------------------------------------------------------------
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create an AWS S3 bucket to offload Open edX file storage.
#------------------------------------------------------------------------------

module "openedx_secrets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> {{ cookiecutter.terraform_aws_modules_s3 }}"

  bucket  = var.resource_name_secrets
  acl     = "private"
  tags    = local.tags

  block_public_acls   = true
  block_public_policy = true

}
