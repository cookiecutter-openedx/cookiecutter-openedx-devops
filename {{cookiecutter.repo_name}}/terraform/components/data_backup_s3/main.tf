#------------------------------------------------------------------------------ 
# written by: Miguel Afonso
#             https://www.linkedin.com/in/mmafonso/
#
# date: Aug-2021
#
# usage: create a non-public S3 Bucket to store data backups from any backend 
#        service.
#------------------------------------------------------------------------------ 
module "data_backup_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.14"

  bucket = var.resource_name
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = false
  }
}

# Generate an additional IAM user with read-only access to the bucket
resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "s3-openedx-user-${random_id.id.hex}"
  path = "/system/s3-bucket-user/"
}

data "aws_iam_policy_document" "user_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      module.data_backup_s3_bucket.s3_bucket_arn
    ]
  }
  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "${module.data_backup_s3_bucket.s3_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket"
  policy = data.aws_iam_policy_document.user_policy.json
  user   = aws_iam_user.user.name
}
