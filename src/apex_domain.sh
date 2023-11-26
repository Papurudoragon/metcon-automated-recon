#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# # Install python requirements. -- no setup file for this

# echo ""
# echo "installing python requirements"
# echo ""
# sleep 1 
# python3 -m pip install ./src/check_mdi/.
# echo ""
# sleep 1

# now grab apex domains with check_mdi tool

echo "Running autodiscover service for Apex domains"
echo ""
sleep 1
python3 ./src/check_mdi/check_mdi.py -d $domain >> "$apex_domain"
sleep 1
