output "tags" {
  value = {
    "cookiecutter/meta/terraform"                      = "true"
    "cookiecutter/meta/version"                        = replace(tostring(data.template_file.cookiecutter_version.rendered), "\n", "")
    "cookiecutter/meta/aws_iam_user"                   = replace(tostring(data.template_file.cookiecutter_global_iam_arn.rendered), "\n", "")
    "cookiecutter/meta/github_repository"              = replace(tostring(data.template_file.cookiecutter_github_repository.rendered), "\n", "")
    "cookiecutter/meta/github_branch"                  = replace(tostring(data.template_file.cookiecutter_github_branch.rendered), "\n", "")
    "cookiecutter/meta/github_commit"                  = replace(tostring(data.template_file.cookiecutter_github_commit.rendered), "\n", "")
    "cookiecutter/meta/github_commit_date"             = replace(tostring(data.template_file.cookiecutter_github_commit_date.rendered), "\n", "")
    "cookiecutter/meta/awscli_version"                 = replace(tostring(data.template_file.cookiecutter_awscli_version.rendered), "\n", "")
    "cookiecutter/meta/terraform_version"              = replace(tostring(data.template_file.cookiecutter_terraform_version.rendered), "\n", "")
    "cookiecutter/meta/kubectl_version"                = replace(tostring(data.template_file.cookiecutter_kubectl_version.rendered), "\n", "")
    "cookiecutter/meta/os"                             = replace(tostring(data.template_file.cookiecutter_os.rendered), "\n", "")
    "cookiecutter/meta/timestamp"                      = replace(tostring(data.template_file.cookiecutter_timestamp.rendered), "\n", "")
  }
}
