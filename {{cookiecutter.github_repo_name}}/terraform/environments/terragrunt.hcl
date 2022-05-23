locals {
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  aws_region      = local.global_vars.locals.aws_region
  account_id      = local.global_vars.locals.account_id
  platform_name   = local.global_vars.locals.platform_name
  platform_region = local.global_vars.locals.platform_region

  environment           = local.environment_vars.locals.environment
  environment_namespace = local.environment_vars.locals.environment_namespace
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", local.account_id)}-terraform-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "${local.environment_namespace}-terraform-lock"
    s3_bucket_tags = {
      Terraform       = "true"
      Platform        = local.platform_name
      Environment     = local.environment
      Platform-Region = local.platform_region
    }
    dynamodb_table_tags = {
      owner           = "terragrunt"
      name            = "Terraform lock table"
      Platform        = local.platform_name
      Terraform       = local.environment
      Platform_Region = local.platform_region
    }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.global_vars.locals,
  local.environment_vars.locals,
)
