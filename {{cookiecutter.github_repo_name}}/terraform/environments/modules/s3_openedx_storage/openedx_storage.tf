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
  version = "{{ cookiecutter.terraform_aws_modules_s3 }}"

  bucket = var.resource_name_storage
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  attach_policy = true
  policy        = data.aws_iam_policy_document.bucket_policy.json

  versioning = {
    enabled = false
  }
}
