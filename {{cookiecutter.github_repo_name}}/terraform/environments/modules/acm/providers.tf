provider "aws" {
  alias  = "environment_region"
  region = var.aws_region
}
