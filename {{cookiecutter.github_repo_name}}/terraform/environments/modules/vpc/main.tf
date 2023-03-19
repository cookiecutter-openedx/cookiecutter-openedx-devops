locals {
  cdn_name         = "cdn.${var.environment_domain}"

  tags = merge(
    var.tags,
    module.cookiecutter_meta.tags,
    {
      "cookiecutter/module/source" = "{{ cookiecutter.github_repo_name }}/terraform/environments/modules/vpn"
    }
  )
}

#------------------------------------------------------------------------------
#                               COOKIECUTTER META
#------------------------------------------------------------------------------
module "cookiecutter_meta" {
  source = "../../../../../../../common/cookiecutter_meta"
}
