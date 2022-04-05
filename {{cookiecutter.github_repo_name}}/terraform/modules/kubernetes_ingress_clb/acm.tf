#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com/
#
# date: Feb-2022
#
# usage: Add tls certs to us-east-1 for Cloudfront distributions.
#------------------------------------------------------------------------------

# FIX NOTE: do we even need this for anything?

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
