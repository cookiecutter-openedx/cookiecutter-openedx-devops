#!/bin/sh
#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       aug-2022
#
# usage:      print the login banner
#------------------------------------------------------------------------------
COLUMNS=78
title="Welcome to the MongoDB Server for ${platform_name}"
sub_title="Created with Cookiecutter for Open edX (tm) Devops"
attribution="https://github.com/cookiecutter-openedx/cookiecutter-openedx-devops"

printf "\n"
printf "*******************************************************************************\n"
printf "*\n"
printf "*%*s\n" $((($${#title}+$COLUMNS)/2)) "$title"
printf "*%*s\n" $((($${#sub_title}+$COLUMNS)/2)) "$sub_title"
printf "*\n"
printf "*%*s\n" $((($${#attribution}+$COLUMNS)/2)) "$attribution"
printf "*\n"
printf "*******************************************************************************\n"
printf "\n"
