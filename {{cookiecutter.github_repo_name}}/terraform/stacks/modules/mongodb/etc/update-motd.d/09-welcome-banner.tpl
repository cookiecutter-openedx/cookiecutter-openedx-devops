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
attribution="https://github.com/lpm0073/cookiecutter-openedx-devops"

printf "\n"
printf "*******************************************************************************\n"
printf "*\n"
{% raw %}printf "*%*s\n" $((($${#title}+$COLUMNS)/2)) "$title"{% endraw %}
{% raw %}printf "*%*s\n" $((($${#sub_title}+$COLUMNS)/2)) "$sub_title"{% endraw %}
printf "*\n"
{% raw %}printf "*%*s\n" $((($${#attribution}+$COLUMNS)/2)) "$attribution"{% endraw %}
printf "*\n"
printf "*******************************************************************************\n"
printf "\n"
