#!/bin/bash
#---------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date:       june-2022
#
# usage:      downloads the complete log file for a
#             pod in a kubernetes cluster.
#--------------------------------------------------------


# echo $0 was called with $# arguments.
if [ $# == 3 ]; then
    $HOME/scripts/kcontext.sh $1 $2
    echo "dumping log for pod $3 in namespace $2 in context $1"
    kubectl logs -n $2 $3 > ~/desktop/$3.log
else
    echo "klog.sh - for Kubernetes context and namespace, dump the log from pod and save to the desktop."
    echo "Usage: ./klog.sh context namespace pod"
    exit 1
fi
