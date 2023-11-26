#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# nmap results for domain
nmap -sC -sV -T4 -A -v $domain -oN $nmap

# now for the real good stuff. naabu for asn ip ranges
echo $asn_ip | naabu -p 80,443 
