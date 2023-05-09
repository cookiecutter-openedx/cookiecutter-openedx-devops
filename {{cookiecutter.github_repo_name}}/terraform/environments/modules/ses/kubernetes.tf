#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:   apr-2023
#
# usage:  store the IAM smpt user key-secret in kubernetes secrets
#         ultimately, the settings persisted in this secret will be
#         used to configure SMTP email service from tutor, using this form:
#
#         tutor config save --set SMTP_HOST=smtp.gmail.com \
#                           --set SMTP_PORT=587 \
#                           --set SMTP_USE_SSL=false  \
#                           --set SMTP_USE_TLS=true \
#                           --set SMTP_USERNAME=YOURUSERNAME@gmail.com \
#                           --set SMTP_PASSWORD='YOURPASSWORD'
#
#         see this thread regarding how to use an IAM key-secret with AWS SES
#         https://stackoverflow.com/questions/45653939/amazon-ses-535-authentication-credentials-invalid-trying-to-rotate-access-key
#------------------------------------------------------------------------------

resource "kubernetes_secret" "smtp_user" {
  metadata {
    name      = "aws-ses-config"
    namespace = var.environment_namespace
  }

  data = {
    OPENEDX_EMAIL_USERNAME     = aws_iam_access_key.smtp_user.id
    OPENEDX_EMAIL_PASSWORD     = base64encode(aws_iam_access_key.smtp_user.secret)
    OPENEDX_EMAIL_HOST         = "email-smtp.${var.aws_region}.amazonaws.com"
    OPENEDX_EMAIL_USE_SSL      = false
    OPENEDX_EMAIL_USE_TLS      = true
    OPENEDX_EMAIL_PORT         = 587
  }
}
