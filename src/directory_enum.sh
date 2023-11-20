#!/bin/bash

# pass $domain flag from main
domain=$1

#set PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

# Source the configuration file
source ./src/config.sh

# create gospider directory
if [ ! -d "gospider" ]; then
    # Directory does not exist, so create it
    mkdir gospider
    echo "Created directory 'gospider'"
else
    # Directory already exists
    echo ""
fi


# start with passive subdomain enum
echo "starting passive directory search..."
sleep 1
gau "$domain" | awk -F/ '{print $3"/"$4}' | sort -u >> $dir_passive
echo "Directories and paths have been saved to $dir_passive"
sleep 1



# Go Spider spidering -c 5 limits reqs to 2 req/ps (this helps with ratelimiting)

echo "formating urls for gospider..."
sleep 1
cat $sorted | httpx >> gospider_formated_urls.txt

echo "Starting gospider directory enumeration (this may take a while...)"
sleep 1
gospider -S gospider_formated_urls.txt -c 2 -d 3 -o ./gospider/
sleep 2

# rm the gpspider url
rm gospider_formated_urls.txt
