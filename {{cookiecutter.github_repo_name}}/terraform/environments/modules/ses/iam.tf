#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:   apr-2023
#
# usage:  create an IAM user with a key-secret credential.
#         attach a mail sending policy to this user account.
#------------------------------------------------------------------------------
data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
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
