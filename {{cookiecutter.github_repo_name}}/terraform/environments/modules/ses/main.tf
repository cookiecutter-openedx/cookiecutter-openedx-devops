#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:   apr-2023
#
# usage:  create AWS SES registered domain
#         create DKIM records for the registered domain
#
# see: https://stackoverflow.com/questions/52850212/terraform-aws-ses-credential-resource
#
#------------------------------------------------------------------------------

locals {

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source" = "openedx_devops/terraform/environments/modules/ses"
    }
  )
}

resource "aws_ses_domain_identity" "environment_domain" {
  domain = var.environment_domain
}

resource "aws_ses_domain_dkim" "environment_domain" {
  domain = aws_ses_domain_identity.environment_domain.domain
}



#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
