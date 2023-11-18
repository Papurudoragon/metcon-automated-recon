#!/bin/bash

# pass $domain flag from main
domain=$1

# added .bash_profile for pathing
BASH_PROFILE="$HOME/.bash_profile"

# Check if .bash_profile exists, if not create it
if [ ! -f "$BASH_PROFILE" ]; then
    touch "$BASH_PROFILE"
    echo "Created $BASH_PROFILE"
fi

# Export PATH variable to .bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$BASH_PROFILE"

# Source .bash_profile
source "$BASH_PROFILE"

# Source the configuration file
source ./src/config.sh


# Using the variables, we can run several commands for subdomain enum
subfinder -d $domain -v >> $output
sleep 1
## sudo sublist3r -d $domain -v >> $output --> install path not specified
amass enum -passive -d $domain -v >> $output
sleep 1
## sudo assetfinder --subs-only $domain >> $output --> install path not specified
findomain -t $domains -v >> $output
sleep 1
