#!/bin/bash

# pull the domain for create the dir
domain=$1
domain_folder="${domain%.com}"

# Generating a timestamp for the current date and time
# Format: YYYY-MM-DD_HH-MM-SS
date=$(date +"%Y-%m-%d")

# mkdir a directory called the domain that user chose
# Check if the $domain/ directory does not exist
if [ ! -d "$domain_folder" ]; then
    # Directory does not exist, so create it
    mkdir $domain_folder
    echo "Created directory '$domain_folder'"
else
    # Directory already exists
    echo ""
fi

# Defining the output file name
output="$domain_folder/output-$date.txt"

# sorted subdomains (remove dups)
sorted="$domain_folder/sorted_subdomains_$date.txt"

#subdomain takeover
subtakeover="$domain_folder/subdomain_takeover_check_$date.txt"

# live subdomains
live="$domain_folder/live_sub_$date.txt"

#nuclei scan results
nuclei="$domain_folder/nuclei_results_$date.txt"

# # spider results
# directories="results/spider_$date.txt" --> not needed

# nmap results
nmap="$domain_folder/nmap_$date.txt"

# dir search
dir_passive="$domain_folders/directory_passive_$date.txt"

git_dorking="$domain_folder/git_dorking_$date.txt"