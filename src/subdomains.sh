#!/bin/bash

# pass $domain flag from main
domain=$1

# Source the configuration file
source ./src/config.sh
source ~/.bash_profile 


# Using the variables, we can run several commands for subdomain enum
subfinder -d $domain -v >> $output
sleep 1
## sudo sublist3r -d $domain -v >> $output --> install path not specified
amass enum -passive -d $domain -v >> $output
sleep 1
## sudo assetfinder --subs-only $domain >> $output --> install path not specified
findomain -t $domains -v >> $output
sleep 1
