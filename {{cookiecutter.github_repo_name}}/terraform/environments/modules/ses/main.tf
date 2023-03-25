#
# see: https://stackoverflow.com/questions/52850212/terraform-aws-ses-credential-resource
#
locals {

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source" = "openedx_devops/terraform/environments/modules/ses"
    }
  )
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_ses_domain_identity" "environment_domain" {
  domain = var.environment_domain
}

resource "aws_ses_domain_dkim" "environment_domain" {
  domain = aws_ses_domain_identity.environment_domain.domain
}

resource "aws_iam_user" "smtp_user" {
  name = "${var.environment_namespace}_smtp_user"
  tags = local.tags
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

resource "aws_iam_policy" "ses_sender" {
  name        = "${var.environment_namespace}_ses_sender"
  description = "Cookiecutter: allow sending e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
  tags        = local.tags
}

resource "aws_iam_user_policy_attachment" "aws_iam_policy_ses_sender" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}


#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
