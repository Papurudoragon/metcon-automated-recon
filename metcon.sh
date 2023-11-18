#!/bin/bash

echo ""
echo ""
echo "██   ██ █████ █████ █████ █████ ██   █"
echo "█ █ █ █ █       █   █     █   █ █ █  █"
echo "█  █  █ ███     █   █     █   █ █  █ █"
echo "█     █ █       █   █     █   █ █   ██"
echo "█     █ █████   █   █████ █████ █    █"

echo ""
echo ""
echo "A Methodology script by ViPv4 (Papv2)"
sleep 2
echo ""
echo ""

# This script goes through a recon methodology
# The script will take quite a bit of time to complete, please allow up to 8 hours for full completion.
echo "The script will take quite a bit of time to complete, please allow adequate time for full completion."
sleep 3
echo ""

# We need to run as root for this ----> borks things for now
# # Check if the script is running as root (sudo privileges)
# if [ "$(id -u)" != "0" ]; then
#     echo "This script must be run as root. Please run with sudo."
#     exit 1
# fi

# Iterate through all .sh files in the main directory and set proper perms
for script in *.sh; do
    # Check if the file is executable
    if [[ -x "$script" ]]; then
        echo "Checking permissions for $script"
        continue
    else
        # Set execute permissions and then execute if its not an executable
        echo "Setting execute permission for $script"
        chmod +x "$script"
        continue
    fi
done
sleep 2


# check if all necessary tools are installed:
echo "making sure that all tools are installed...."
echo ""
sleep 1
install.sh
echo ""
echo "done... moving onto step 1"
sleep 1
echo ""

# Set proper permissions for execution in src
# Iterate through all .sh files in the src directory
for script in src/*.sh; do
    # Check if the file is executable
    if [[ -x "$script" ]]; then
        echo "checking permissions for $script"
        continue
    else
        # Set execute permissions and then execute if its not an executable
        echo "Setting execute permission for $script.."
        chmod +x "$script"
    fi
done
sleep 2

# Assigning the first command-line argument to 'domain'
domain=$1

# Check if domain argument was provided
if [ -z "$domain" ]; then
    echo "Usage: $0 domain"
    exit 1
fi

# Source the configuration file
source ./src/config.sh

#let's start with the subdomain enumeration
echo "Enumerating subdomains, please wait......"
echo ""
sleep 1
./src/subdomains.sh $domain $output
echo ""
sleep 1
echo ""
echo "unsorted subdomains have been saved to $output."

# remove the duplicate subdomains
echo "sorting subdomains and removing duplicates...."
sleep 1
echo ""
sort $output | uniq > $sorted
echo ""
echo "Duplicates have been sorted and new output is saved in $sorted"
echo ""
sleep 1

# Check for subdomain takeover
echo "checking for subdomain takeover...."
sleep 1
echo ""
subzy run --targets $output > $subtakeover
echo ""
echo "results saved in $subtakover" 
sleep 1
echo ""

# Check and verify that the subdomains are live.. Also include the technologies used, status codes, and content length
echo "checking for live subdomains....... [also grabbing ip, technology used, status code, and content length..]"
sleep 1
echo ""
cat $live | httpx -sc -cl -ip -td -v > $live
echo "Output can be found in $live..."
echo ""
sleep 1
echo ""


# Vuln scan the live subdomains with nuclei
./src/vulnscan.sh
echo ""
sleep 1
echo ""


# port scan
echo "starting portscan....."
sleep 1
echo ""
./src/portscan.sh
echo ""
echo "completed, portscan results can be found in $nmap.."
sleep 1
echo ""


# Moving on to directory brute force
echo "starting directory brute forcing... (reqs are set to 2 reqs/ps to avoid being rate limited)"
echo ""
./src/directory_enum.sh
echo ""
echo "directory results can be found in $directories"
echo ""
sleep 1

### TO DO
# Date is not working correctly, need to find a better way to do this...