#!/bin/bash
#------------------------------------------------------------------------------
# written by:   Lawrence McDaniel
#               https://lawrencemcdaniel.com
#
# date:         aug-2022
#
# usage:        query DNS record entries from AWS Route53
#------------------------------------------------------------------------------

# echo $0 was called with $# arguments.
if [ $# == 1 ]; then
    $HOME/scripts/kcontext.sh $1 $2
    echo "Retrieving DNS records for domain $1"

    # query AWS Route53 zoneId based on root domain name.
    hostedzoneid=$(aws route53 list-hosted-zones --output json | jq -r ".HostedZones[] | select(.Name == \"$1.\") | .Id" | cut -d'/' -f3)

    # use Route53 zoneEd to query the DNS record entries
    # then use jq to parse the json result into row-level data.
    aws route53 list-resource-record-sets --hosted-zone-id $hostedzoneid --output json | jq -jr '.ResourceRecordSets[] | "\(.Name) \t\(.TTL) \t\(.Type) \t\(.ResourceRecords[]?.Value)\n"'

else
    echo "dns.sh - Dumps the DNS record entries for an AWS Route53-managed domain name."
    echo "Usage: ./dns.sh domain_name"
    exit 1
fi
