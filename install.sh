#!/bin/bash

# pull the domain for create the dir
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# Check and install basic utilities
install_basic_utility() {
    local utility=$1
    local install_cmd=$2

    if ! command -v $utility &> /dev/null; then
        echo "$utility is not installed, installing..."
        eval $install_cmd
    else
        echo "$utility is already installed."
    fi
}

# Check and install wget and tar if not present
install_basic_utility "wget" "sudo apt-get install wget -y"
install_basic_utility "tar" "sudo apt-get install tar -y"
install_basic_utility "snapd" "sudo apt-get install snapd -y"

# Function to install Go
install_go() {
    echo "Installing Go..."
    # Fetch the latest version of Go

    # Hard-coded URL for the specific version of Go ---> need to update this later to be dynamic
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
    sleep 1

    echo "Extracting Go..."
    sudo tar -C /usr/local -xzf go.tar.gz
    if [ $? -ne 0 ]; then
        echo "Failed to extract Go."
        return 1
    fi

    rm go.tar.gz
    echo "Go installed successfully."
}

# Function to check and install a tool
install_tool() {
    local tool=$1
    local install_cmd=$2

    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found, installing..."
        eval $install_cmd
        if ! $install_cmd; then
            echo "Failed to install $tool. Please check the installation command or your environment."
            return 1
        fi
    else
        echo "$tool is already installed."
    fi
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    install_go
fi

# Tools and their installation commands
declare -A tools_install_cmds
tools_install_cmds[subfinder]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
tools_install_cmds[amass]="sudo snap install amass"
tools_install_cmds[findomain]="wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O /usr/local/bin/findomain && chmod +x /usr/local/bin/findomain"
tools_install_cmds[subzy]="go install -v github.com/LukaSikic/subzy@latest"
tools_install_cmds[httpx]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
tools_install_cmds[nuclei]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
tools_install_cmds[nmap]="sudo apt-get install nmap -y"
tools_install_cmds[gospider]="go install -v github.com/jaeles-project/gospider@latest"
tools_install_cmds[gau]="go install github.com/lc/gau/v2/cmd/gau@latest"

# Check and install each tool
for tool in "${!tools_install_cmds[@]}"; do
    install_tool $tool "${tools_install_cmds[$tool]}"
done

# Ensure GOPATH and PATH are set correctly
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go
