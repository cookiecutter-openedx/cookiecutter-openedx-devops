#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       Aug-2022
#
# usage: generate a report of historical EC2 spot prices
#        for t3.medium instances type over the last 12
#        hours.
#--------------------------------------------------------

TIMESTAMP=`date -v-12H +%Y-%m-%dT%H:%M:%S`
aws ec2 describe-spot-price-history --instance-types t3.medium --product-description Linux/UNIX --start-time ${TIMESTAMP}
