output "tags" {
  value = {
    "cookiecutter/meta/terraform"          = "true"
    "cookiecutter/meta/version"            = replace(tostring(data.local_file.cookiecutter_version.content), "\n", "")
    "cookiecutter/meta/aws_iam_user"       = replace(tostring(data.local_file.cookiecutter_global_iam_arn.content), "\n", "")
    "cookiecutter/meta/github_repository"  = replace(tostring(data.local_file.cookiecutter_github_repository.content), "\n", "")
    "cookiecutter/meta/github_branch"      = replace(tostring(data.local_file.cookiecutter_github_branch.content), "\n", "")
    "cookiecutter/meta/github_commit"      = replace(tostring(data.local_file.cookiecutter_github_commit.content), "\n", "")
    "cookiecutter/meta/github_commit_date" = replace(tostring(data.local_file.cookiecutter_github_commit_date.content), "\n", "")
    "cookiecutter/meta/awscli_version"     = replace(tostring(data.local_file.cookiecutter_awscli_version.content), "\n", "")
    "cookiecutter/meta/terraform_version"  = replace(tostring(data.local_file.cookiecutter_terraform_version.content), "\n", "")
    "cookiecutter/meta/kubectl_version"    = replace(tostring(data.local_file.cookiecutter_kubectl_version.content), "\n", "")
    "cookiecutter/meta/os"                 = replace(tostring(data.local_file.cookiecutter_os.content), "\n", "")
    "cookiecutter/meta/timestamp"          = replace(tostring(data.local_file.cookiecutter_timestamp.content), "\n", "")
  }

  depends_on = [
    null_resource.environment
  ]
}
