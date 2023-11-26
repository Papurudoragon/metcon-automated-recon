#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# we gotta get ASN info, to do that we need to strip the .com, and domain_folder does that automatically
# grab the ip and name to verify later
echo ""
echo "grabbing ASN: IPv4 and Name"
curl -X GET "https://api.bgpview.io/search?query_term=$domain_folder" | jq -r '.data.ipv4_prefixes[] | "\(.ip) - \(.name)"' >> $asn_findings
echo ""
sleep 1
sort -u $asn_ip > $asn_ip
sleep 2
echo "ASN information can be found in $asn_findings."
echo "ASN ip addresses only can be found in $asn_ip."


# now trim to also just grab the ip
echo ""
echo "sorting the results and making a copy with just the ips..."
sleep 1
cut -d ' ' -f 1 $asn_findings > $asn_ip
# curl -X GET "https://api.bgpview.io/search?query_term=$domain_folder" | jq -r '.data.ipv4_prefixes[] | "\(.ip)"' >> $asn_ip ---> not used anymore
echo ""
echo "output can be found in $asn_ip" 
sleep 2
