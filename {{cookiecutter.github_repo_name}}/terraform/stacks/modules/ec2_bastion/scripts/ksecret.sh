#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage:      echos an unencrypted secret value to the
#             console.
#--------------------------------------------------------

if [ $# == 2 ]; then
    echo "get k8s secreet $1 from namespace $2"

    kubectl get secret $1 -n $2  -o json | jq  '.data | map_values(@base64d)' |   jq -r 'keys[] as $k | "export \($k|ascii_upcase)=\(.[$k])"'
else
    echo "Usage: ./ksecret.sh secret namespace "
    exit 1
fi
