#!/bin/bash

# Source the configuration file
source ./src/config.sh
source ~/.bash_profile 


# Using the variables, we can run several commands for subdomain enum
sudo subfinder -d $domain -v > $output
sudo sublist3r -d $domain -v >> $output
sudo amass enum -passive -d $domain >> $output
sudo assetfinder --subs-only $domain >> $output
sudo findomain -t $domains >> $output

