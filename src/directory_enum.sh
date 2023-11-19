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

# Go Spider spidering -c 5 limits reqs to 2 req/ps (this helps with ratelimiting)

echo "formating urls for gospider..."
sleep 1
cat $sorted | httpx >> gospider_formated_urls.txt

echo "Starting gospider directory enumeration (this may take a while...)"
sleep 1
gospider -s gospider_formated_urls.txt -c 2 -d 3 --robots -o ./gospider/
sleep 2

rm gospider_formated_urls.txt
