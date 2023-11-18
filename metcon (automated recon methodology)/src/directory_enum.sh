#! /bin/sh

# Source the configuration file
source config.sh
source ../metcon.sh

# Go Spider spidering -c 5 limits reqs to 2 req/ps (this helps with ratelimiting)
echo "Starting gospider directory enumeration (this may take a while...)"
gospider -s $domain -c 2 -d 3 --robots > $spider
sleep 2