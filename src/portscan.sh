#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# Nmap
nmap -sC -sV -T4 -A -v $domain -oN $nmap
