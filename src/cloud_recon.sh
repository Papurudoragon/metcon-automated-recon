#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# cloud recon with CloudRecon
# get the scanned txt file and parse it