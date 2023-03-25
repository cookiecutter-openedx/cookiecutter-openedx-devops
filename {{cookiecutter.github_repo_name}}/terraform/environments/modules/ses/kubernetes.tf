#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: mar-2023
#
# usage:  store the IAM smpt user key-secret in kubernetes secrets
#
#------------------------------------------------------------------------------
# --set SMTP_HOST=smtp.gmail.com \
# --set SMTP_PORT=587 \
# --set SMTP_USE_SSL=false  \
# --set SMTP_USE_TLS=true \
# --set SMTP_USERNAME=YOURUSERNAME@gmail.com \
# --set SMTP_PASSWORD='YOURPASSWORD'

resource "kubernetes_secret" "smtp_user" {
  metadata {
    name      = "aws-ses-config"
    namespace = var.environment_namespace
  }

  data = {
    SMTP_USERNAME     = aws_iam_access_key.smtp_user.id
    SMTP_PASSWORD     = aws_iam_access_key.smtp_user.secret
    SMTP_HOST         = "email-smtp.${var.aws_region}.amazonaws.com"
    SMTP_USE_SSL      = false
    SMTP_USE_TLS      = true
    SMTP_PORT         = 587
  }
}
