#!/bin/sh
#------------------------------------------------------------------------------
# written by:   mcdaniel
#               https://lawrencemcdaniel.com
#
# date:         mar-2022
#
# usage:        Runs terraform fmt -recursive
#------------------------------------------------------------------------------

terraform fmt -recursive
pre-commit run --all-files
