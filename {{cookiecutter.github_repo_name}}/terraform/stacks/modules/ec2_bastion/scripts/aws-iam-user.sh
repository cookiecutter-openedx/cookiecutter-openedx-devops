#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       Mar-2023
#
# usage:      returns the IAM user ARN to which the
#             awscli key-secret belong.
#--------------------------------------------------------

PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/ubuntu/scripts:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
AWS_CONFIG_FILE=/home/ubuntu/.aws/config

/home/linuxbrew/.linuxbrew/bin/aws sts get-caller-identity | jq -r '.["Arn"] as $v | "\($v)"'
