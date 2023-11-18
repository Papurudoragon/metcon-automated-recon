#!/bin/bash

# Source the configuration file
source ./src/config.sh

# Nmap
sudo nmap -sS -sU -T4 -A -v $domain -o $nmap
