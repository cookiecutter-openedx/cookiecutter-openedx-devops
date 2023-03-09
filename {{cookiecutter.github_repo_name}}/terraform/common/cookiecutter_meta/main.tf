#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Mar-2023
#
# usage: gather environment variables and add to a tags dict
#------------------------------------------------------------------------------

resource "null_resource" "cookiecutter_github_commit_date" {
  provisioner "local-exec" {
    command = <<-EOT
    cookiecutter_github_commit_date=$(date -r $(git log -1 --format=%ct) +%Y%m%dT%H%M%S)
    echo $cookiecutter_github_commit_date > ${path.module}/output/cookiecutter_github_commit_date.state
    EOT
  }
}
data "template_file" "cookiecutter_github_commit_date" {
  template = file("${path.module}/output/cookiecutter_github_commit_date.state")
  depends_on = [
    null_resource.cookiecutter_github_commit_date
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_terraform_version" {
  provisioner "local-exec" {
    command = <<-EOT
    cookiecutter_terraform_version=$(terraform --version | head -n 1 | sed 's/Terraform //')
    echo $cookiecutter_terraform_version > ${path.module}/output/cookiecutter_terraform_version.state
    EOT
  }
}
data "template_file" "cookiecutter_terraform_version" {
  template = file("${path.module}/output/cookiecutter_terraform_version.state")
  depends_on = [
    null_resource.cookiecutter_terraform_version
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_timestamp" {
  provisioner "local-exec" {
    command = <<-EOT
    cookiecutter_timestamp=$(date +%Y%m%dT%H%M%S)
    echo $cookiecutter_timestamp > ${path.module}/output/cookiecutter_timestamp.state
    EOT
  }
}
data "template_file" "cookiecutter_timestamp" {
  template = file("${path.module}/output/cookiecutter_timestamp.state")
  depends_on = [
    null_resource.cookiecutter_timestamp
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_os" {
  provisioner "local-exec" {
    command = <<-EOT
      echo $OSTYPE > ${path.module}/output/cookiecutter_os.state
      EOT
  }
}
data "template_file" "cookiecutter_os" {
  template = file("${path.module}/output/cookiecutter_os.state")
  depends_on = [
    null_resource.cookiecutter_os
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_github_repository" {
  provisioner "local-exec" {
    command = <<-EOT
    GIT_PARENT_DIRECTORY=$(git rev-parse --show-toplevel)
    cookiecutter_github_repository=$(git -C $GIT_PARENT_DIRECTORY config --get remote.origin.url)
    echo $cookiecutter_github_repository > ${path.module}/output/cookiecutter_github_repository.state
    EOT
  }
}
data "template_file" "cookiecutter_github_repository" {
  template = file("${path.module}/output/cookiecutter_github_repository.state")
  depends_on = [
    null_resource.cookiecutter_github_repository
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_github_branch" {
  provisioner "local-exec" {
    command = <<-EOT
    GIT_PARENT_DIRECTORY=$(git rev-parse --show-toplevel)
    cookiecutter_github_branch=$(git -C $GIT_PARENT_DIRECTORY branch | sed 's/* //')
    echo $cookiecutter_github_branch > ${path.module}/output/cookiecutter_github_branch.state
    EOT
  }
}
data "template_file" "cookiecutter_github_branch" {
  template = file("${path.module}/output/cookiecutter_github_branch.state")
  depends_on = [
    null_resource.cookiecutter_github_branch
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_github_commit" {
  provisioner "local-exec" {
    command = <<-EOT
    GIT_PARENT_DIRECTORY=$(git rev-parse --show-toplevel)
    cookiecutter_github_commit=$(git -C $GIT_PARENT_DIRECTORY rev-parse HEAD)
    echo $cookiecutter_github_commit > ${path.module}/output/cookiecutter_github_commit.state
    EOT
  }
}
data "template_file" "cookiecutter_github_commit" {
  template = file("${path.module}/output/cookiecutter_github_commit.state")
  depends_on = [
    null_resource.cookiecutter_github_commit
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_global_iam_arn" {
  provisioner "local-exec" {
    command = <<-EOT
      cookiecutter_global_iam_arn=$(aws sts get-caller-identity | jq -r '.["Arn"] as $v | "\($v)"')
      echo $cookiecutter_global_iam_arn > ${path.module}/output/cookiecutter_global_iam_arn.state
    EOT
  }
}
data "template_file" "cookiecutter_global_iam_arn" {
  template = file("${path.module}/output/cookiecutter_global_iam_arn.state")
  depends_on = [
    null_resource.cookiecutter_global_iam_arn
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_kubectl_version" {
  provisioner "local-exec" {
    command = <<-EOT
      cookiecutter_kubectl_version=$(kubectl version --output=json | jq -r '.["clientVersion"].gitVersion as $v | "\($v)"')
      echo $cookiecutter_kubectl_version > ${path.module}/output/cookiecutter_kubectl_version.state
      EOT
  }
}
data "template_file" "cookiecutter_kubectl_version" {
  template = file("${path.module}/output/cookiecutter_kubectl_version.state")
  depends_on = [
    null_resource.cookiecutter_kubectl_version
  ]
}

#--------------------------------------
resource "null_resource" "cookiecutter_awscli_version" {
  provisioner "local-exec" {
    command = <<-EOT
      cookiecutter_awscli_version=$(aws --version | awk '{print $1}' | sed 's/aws-cli//')
      cookiecutter_awscli_version=$cookiecutter_awscli_version:1
      echo $cookiecutter_awscli_version > ${path.module}/output/cookiecutter_awscli_version.state
      EOT
  }
}
data "template_file" "cookiecutter_awscli_version" {
  template = file("${path.module}/output/cookiecutter_awscli_version.state")
  depends_on = [
    null_resource.cookiecutter_awscli_version
  ]
}
