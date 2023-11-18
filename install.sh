#!/bin/bash

# Source the configuration file
source ./src/config.sh

# Function to install Go
install_go() {
    echo "Installing Go..."

    # Fetch the latest version of Go
    local go_url=$(curl -s https://go.dev/dl/ | grep -oP 'https://dl.google.com/go/go[0-9]+\.[0-9]+\.[0-9]+\.linux-amd64.tar.gz' | head -1)

    # Download and extract Go
    wget -q -O go.tar.gz $go_url
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz

    ## Set Go environment variables -----> I do not want to cause permanent changes with this method.
    #echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> "$HOME/.bashrc"
    #echo "export GOPATH=\$HOME/go" >> "$HOME/.bashrc"

    # Source .bashrc to update current session
    #source "$HOME/.bashrc"
}

# Function to check and install a tool
install_tool() {
    local tool=$1
    local install_cmd=$2

    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found, installing..."
        eval $install_cmd
    else
        echo "$tool is already installed."
    fi
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    install_go
fi

# Ensure GOPATH and PATH are set correctly
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

# Tools and their installation commands
declare -A tools_install_cmds
declare -A tools_install_cmds
tools_install_cmds[subfinder]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
tools_install_cmds[sublist3r]="sudo apt-get install sublist3r -y"
tools_install_cmds[amass]="sudo snap install amass"
tools_install_cmds[assetfinder]="go install -v github.com/tomnomnom/assetfinder@latest"
tools_install_cmds[findomain]="wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O /usr/local/bin/findomain && chmod +x /usr/local/bin/findomain"
tools_install_cmds[subzy]="go install -v github.com/lukasikic/subzy@latest"
tools_install_cmds[httpx]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
tools_install_cmds[nuclei]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
tools_install_cmds[nmap]="sudo apt-get install nmap -y"
tools_install_cmds[gospider]="go install -v github.com/jaeles-project/gospider@latest"

# Check and install each tool
for tool in "${!tools_install_cmds[@]}"; do
    install_tool $tool "${tools_install_cmds[$tool]}"
done
