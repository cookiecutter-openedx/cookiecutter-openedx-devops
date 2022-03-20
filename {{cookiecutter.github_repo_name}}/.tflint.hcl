#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date: mar-2022
#
# usage: config file for pre-commit hook tflint.
#        see https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/config.md
#------------------------------------------------------------------------------

config {
  plugin_dir = "~/.tflint.d/plugins"

  module              = true
  force               = false
  disabled_by_default = false

  # un-comment to remove modules from tflint pre-commit hook.
  #ignore_module = {
  #  "terraform-aws-modules/security-group/aws" = true
  #}

  # un-comment to set variables
  #varfile = ["example1.tfvars", "example2.tfvars"]
  #variables = ["foo=bar", "bar=[\"baz\"]"]
}

plugin "aws" {
  enabled    = true
  deep_check = false
  version    = "0.12.0"
  source     = "github.com/terraform-linters/tflint-ruleset-aws"
}

# example pattern to disable a tflint validation rule
#rule "aws_instance_invalid_type" {
#  enabled = false
#}
