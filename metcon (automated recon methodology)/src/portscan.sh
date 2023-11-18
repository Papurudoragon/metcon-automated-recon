#! /bin/sh

# Source the configuration file
source config.sh
source ../metcon.sh

# Nmap
nmap -sS -sU -T4 -A -v $domain -o $nmap
