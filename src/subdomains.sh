#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# set PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

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
# Loop through each domain in the file
while IFS= read -r domain; do
    echo "Running subfinder for domain: $domain"
    # Run subfinder and append results to the output file
    subfinder -d "$domain" -v >> "$output"
done < "$apex_domain"
sleep 2


## sudo sublist3r -d $domain -v >> $output --> install path not specified
while IFS= read -r domain; do
    echo "Running amass for domain: $domain"
    # Run subfinder and append results to the output file
    amass enum --passive -d $apex_domain -v >> "$output"
done < "$apex_domain"
sleep 2
## sudo assetfinder --subs-only $domain >> $output --> install path not specified
# findomain -t $domains -v >> $output ---> need to work on this
# sleep 1


# shosubgo enumeration --- This should only run if a key is found, else it should skip.
echo "checking for shodan api key... please save the shodan api key in ~/.shodan_token"
sleep 3
key=$(cat ~/.shodan_token 2>/dev/null)

if [ -z "$key" ]; then
    echo "No Shodan API key found. Skipping Shosubgo."
else
    shosubgo -d $domain -s $key >> "$output"
fi

