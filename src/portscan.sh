#!/bin/bash

# pass $domain flag from main
domain=$1

# Source the configuration file
source ./src/config.sh

# Nmap
sudo nmap -sS -sU -T4 -A -v $domain -oN $nmap
