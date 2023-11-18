#!/bin/bash

# Hard-coded URL for the specific version of Go
go_url="https://go.dev/dl/go1.21.4.linux-amd64.tar.gz"

# Download the specified version of Go
echo "Downloading Go from $go_url..."
wget -O go.tar.gz $go_url

# Check if the download was successful
if [ ! -f go.tar.gz ]; then
    echo "Failed to download Go."
    exit 1
fi

echo "Download completed."

