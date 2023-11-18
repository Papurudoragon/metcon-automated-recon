#!/bin/sh

# Source the configuration file
source config.sh
source ../metcon.sh

# Using the variables, we can run several commands for subdomain enum
subfinder -d $domain -v > $output
sublist3r -d $domain -v >> $output
amass enum -passive -d $domain >> $output
assetfinder --subs-only $domain >> $output
findomain -t $domains >> $output

