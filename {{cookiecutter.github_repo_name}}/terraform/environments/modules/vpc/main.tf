locals {
  s3_bucket_name   = var.resource_name
  s3_bucket_domain = "${local.s3_bucket_name}.s3.${var.aws_region}.amazonaws.com"
  cdn_name         = "cdn.${var.environment_domain}"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source"    = "{{ cookiecutter.github_repo_name }}/terraform/environments/modules/vpn"
    }
  )
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
