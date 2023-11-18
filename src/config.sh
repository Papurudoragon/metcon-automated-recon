#!/bin/bash

# config.sh

# Generating a timestamp for the current date and time
# Format: YYYY-MM-DD_HH-MM-SS
date=$(date +"%Y-%m-%d")

# mkdir a directory called results/
# Check if the results/ directory does not exist
if [ ! -d "results" ]; then
    # Directory does not exist, so create it
    mkdir results
    echo "Created directory 'results'"
else
    # Directory already exists
    echo ""
fi

# Defining the output file name
output="results/output-$date.txt"

# sorted subdomains (remove dups)
sorted="results/sorted_subdomains_$date.txt"

#subdomain takeover
subtakeover="results/subdomain_takeover_check_$date.txt"

# live subdomains
live="results/live_sub_tech_$date.txt"

#nuclei scan results
nuclei="results/nuclei_results_$date.txt"

# # spider results
# directories="results/spider_$date.txt" --> not needed

# nmap results
nmap="results/namp_$date.txt"