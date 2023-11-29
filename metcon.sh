#!/bin/bash

# Check if the script is being run as root (sudo)
if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root as it will bork env variables. Please run without sudo."
    exit 1
fi

echo ""
echo ""
echo "██   ██ █████ █████ █████ █████ ██   █"
echo "█ █ █ █ █       █   █     █   █ █ █  █"
echo "█  █  █ ███     █   █     █   █ █  █ █"
echo "█     █ █       █   █     █   █ █   ██"
echo "█     █ █████   █   █████ █████ █    █"

echo ""
echo ""
echo "A Methodology script by ViPv4 (Papv2)"
sleep 2
echo ""
echo ""

sudo chmod +x *
sudo chmod 774 ./src/*
# sudo chmod 774 ./src/check_mdi/*


# Prompt for sudo password at the beginning.
echo "Please enter your password to proceed."
sudo -v

# This script goes through a recon methodology
# The script will take quite a bit of time to complete, please allow up to 8 hours for full completion.
echo "The script will take quite a bit of time to complete, please allow adequate time for full completion."
sleep 3
echo ""

# Assigning the first command-line argument to 'domain'
domain=$1
domain_folder="${domain%.com}"

# We need to run as root for this ----> borks things for now
# # Check if the script is running as root (sudo privileges)
# if [ "$(id -u)" != "0" ]; then
#     echo "This script must be run as root. Please run with sudo."
#     exit 1
# fi

# Generating a timestamp for the current date and time
# Format: YYYY-MM-DD_HH-MM-SS
date=$(date +"%Y-%m-%d")

# mkdir a directory called the domain that user chose
# Check if the $domain/ directory does not exist
if [ ! -d "$domain_folder" ]; then
    # Directory does not exist, so create it
    mkdir $domain_folder
    echo "Created directory '$domain_folder'"
else
    # Directory already exists
    echo ""
fi

sudo chmod 774 *
sudo chmod 774 $domain_folder/*

# Defining the output file name
output="$domain_folder/output-$date.txt"

# sorted subdomains (remove dups)
sorted="$domain_folder/sorted_subdomains_$date.txt"

#subdomain takeover
subtakeover="$domain_folder/subdomain_takeover_check_$date.txt"

# live subdomains
live="$domain_folder/live_sub_$date.txt"

#nuclei scan results
nuclei="$domain_folder/nuclei_results_$date.txt"

# # spider results
# directories="results/spider_$date.txt" --> not needed

# nmap results
nmap="$domain_folder/nmap_$date.txt"

# dir search
dir_passive="$domain_folders/directory_passive_$date.txt"

# git dorking
git_dorking="$domain_folder/git_dorking_$date.txt"

# apex domains
apex_domain="$domain_folder/apex_domains_$date.txt"

# ASN
asn_ip="$domain_folder/asn_ip_$date.txt"
asn_findings="$domain_folder/asn_findings_$date.txt"

# Iterate through all .sh files in the main directory and set proper perms
for script in *.sh; do
    # Check if the file is executable
    if [[ -x "$script" ]]; then
        echo "Checking permissions for $script"
        continue
    else
        # Set execute permissions and then execute if its not an executable
        echo "Setting execute permission for $script"
        chmod +x "$script"
        continue
    fi
done
sleep 2


######################################## check if all necessary tools are installed: ###################################
echo "making sure that all tools are installed...."
echo ""
sleep 1

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

    # Ensure GOPATH and PATH are set correctly
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    export GOPATH=$HOME/go
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

# Ensure GOPATH and PATH are set correctly ---> just making sure on this one, its a dup for a reason
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

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
tools_install_cmds[python3]="sudo apt install python3 -y" 
tools_install_cmds[jq]="sudo apt install jq -y"
tools_install_cmds[shosubgo]="go install github.com/incogbyte/shosubgo@latest"
tools_install_cmds[dnspython]="python3 -m pip install dnspython"
tools_install_cmds[htmlq]="sudo snap install htmlq"

# Check and install each tool
for tool in "${!tools_install_cmds[@]}"; do
    install_tool $tool "${tools_install_cmds[$tool]}"
done

echo ""
echo "done... moving onto step 1"
sleep 1
echo ""

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

# Set proper permissions for execution in src
# Iterate through all .sh files in the src directory
for script in src/*.sh; do
    # Check if the file is executable
    if [[ -x "$script" ]]; then
        echo "checking permissions for $script"
        continue
    else
        # Set execute permissions and then execute if its not an executable
        echo "Setting execute permission for $script.."
        chmod +x "$script"
    fi
done
sleep 2

# Check if domain argument was provided
if [ -z "$domain" ]; then
    echo "Usage: $0 domain"
    exit 1
fi

######################################## Lets start Apex Domain enumeration ###################################
sleep 1
echo ""
# # Install python requirements. -- no setup file for this

# echo ""
# echo "installing python requirements"
# echo ""
# sleep 1 
# python3 -m pip install ./src/check_mdi/.
# echo ""
# sleep 1

# now grab apex domains with check_mdi tool

echo "Running autodiscover service for Apex domains"
echo ""
sleep 1
python3 ./src/check_mdi/check_mdi.py -d $domain >> "$apex_domain"
sleep 1
echo ""
echo "output has been saved to $apex_domain"
echo ""
sleep 1

######################################## grab relationship domains ###################################
echo ""
echo ""
echo "grabbing relational domains..."
bash ./src/relation.sh -d $domain
echo ""
sleep 1
mv ./$domain/* $domain_folder
echo ""
echo "Output has been moved to $domain_folder" 
sleep 1 


######################################## lets grab ASN and prepare for port scanning ###################################
echo ""
# we gotta get ASN info, to do that we need to strip the .com, and domain_folder does that automatically
# grab the ip and name to verify later
echo ""
echo "grabbing ASN: IPv4 and Name"
curl -X GET "https://api.bgpview.io/search?query_term=$domain_folder" | jq -r '.data.ipv4_prefixes[] | "\(.ip) - \(.name)"' >> $asn_findings
echo ""
sleep 1
sort -u $asn_ip > $asn_ip
sleep 2
echo "ASN information can be found in $asn_findings."
echo "ASN ip addresses only can be found in $asn_ip."


######################################## now trim to also just grab the ip ###################################
echo ""
echo "sorting the results and making a copy with just the ips..."
sleep 1
cut -d ' ' -f 1 $asn_findings > $asn_ip
# curl -X GET "https://api.bgpview.io/search?query_term=$domain_folder" | jq -r '.data.ipv4_prefixes[] | "\(.ip)"' >> $asn_ip ---> not used anymore
echo ""
echo "output can be found in $asn_ip" 
echo ""
sleep 1
echo ""

######################################## now we take the subdomains of the apex domains with subfinder and amass ###################################
echo "Enumerating subdomains, please wait......"
echo ""
sleep 1
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

echo ""
sleep 1
echo ""
echo "unsorted subdomains have been saved to $output."

######################################## remove the duplicate subdomains ###################################
echo "sorting subdomains and removing duplicates...."
sleep 1
echo ""
sort $output | uniq > $sorted
echo ""
echo "Duplicates have been sorted and new output is saved in $sorted"
echo ""
sleep 1

######################################## Check for subdomain takeover ###################################
echo "checking for subdomain takeover, please wait a few minutes....."
sleep 1
echo ""
subzy run --targets $sorted  >> $subtakeover
echo ""
echo "results saved in $subtakover" 
sleep 1
echo ""

######################################## Check and verify that the subdomains are live.. Also include the technologies used, status codes, and content length ###################################
echo "checking for live subdomains......."
sleep 1
echo ""
cat $sorted | httpx > $live
echo "Output can be found in $live..."
echo ""
sleep 1
echo ""


######################################## port scan ###################################
echo "starting portscan....."
sleep 1
echo ""
# nmap results for domain
nmap -sC -sV -T4 -A -v $domain -oN $nmap

# now for the real good stuff. naabu for asn ip ranges
echo $asn_ip | naabu -p 80,443 
echo ""
echo "completed, portscan results can be found in $nmap.."
sleep 1
echo ""


######################################## Moving on to git_dorking ###################################
# echo "skipping github dorking until updates are applied to the script to avoid API rate limiting..... (also requires github api..)"
# echo ""
# sleep 1
# # github token path
# TOKEN_FILE_PATH="$HOME/.git_access_key/access_key"

# # Function to provide instructions for creating the token file
# create_token_instructions() {
#     echo "GitHub token not found."
#     echo "Please create a file at $TOKEN_FILE_PATH with your GitHub token."
#     echo "You can do this with the following commands:"
#     echo "  mkdir -p ~/.git_access_key"
#     echo "  echo 'your_github_key_here' > $TOKEN_FILE_PATH"
#     echo "  chmod 600 $TOKEN_FILE_PATH"
#     echo "Replace 'your_github_key_here' with your actual GitHub token."
# }


# # Check if the token file exists and read the token
# if [ -f "$TOKEN_FILE_PATH" ]; then
#     GITHUB_TOKEN=$(cat "$TOKEN_FILE_PATH")
# else
#     create_token_instructions
#     echo "skipping the github dorking step......"
#     sleep 5
#     exit 1 # This should continue the code instead of exiting if no token was found.
# fi



# # Array of GitHub dorks to use
# declare -a dorks=(
#     "filename:.env DB_USERNAME DB_PASSWORD"
#     "filename:docker-compose.yml MYSQL_ROOT_PASSWORD"
#     "filename:.htpasswd"
#     "filename:.git-credentials"
#     "path:/root/ filename:wp-config.php"
#     "filename:.bash_history"
#     "filename:id_rsa or filename:id_dsa"
#     "filename:.npmrc _auth"
#     "filename:.dockercfg auth"
#     "extension:pem private"
#     "filename:.pgpass"
#     "filename:.s3cfg"
#     "filename:wp-config.php"
#     "filename:.travis.yml AWS_ACCESS_KEY_ID"
#     "filename:.bashrc password"
#     "filename:.bash_profile aws"
#     "HEROKU_API_KEY language:json"
#     "filename:.netrc password"
#     "filename:_netrc password"
#     "filename:hub oauth_token"
#     "filename:robomongo.json"
#     "filename:.npmrc NPM_TOKEN"
#     "filename:.eslintrc AWS_SECRET_ACCESS_KEY"
#     "filename:.travis.yml secure"
#     "HOMEBREW_GITHUB_API_TOKEN language:shell"
#     "filename:.bashrc mailchimp"
#     "filename:.gitconfig token"
#     "filename:.bashrc stripe"
#     "filename:.bash_profile heroku"
#     "filename:credentials aws_access_key_id"
#     "filename:config irc_pass"
#     "extension:sql mysql dump"
#     "extension:sql site:github.com"
#     "filename:dump.sql"
#     "filename:backup.zip"
#     "filename:backup.tar.gz"
#     "filename:.sql.gz"
#     "filename:credentials.json"
#     "extension:json api_key"
#     "extension:json api_secret"
#     "filename:.pgpass"
# echo ""
# # echo "directory results can be found in ./$git_dorking/"
# echo ""
# sleep 1

######################################## Vuln scan the live subdomains with nuclei ###################################
echo "starting nuclei vuln scanning..."
sleep 1
# First update nuclei templates
nuclei -update-templates
sleep 2

# Not sure where Nuclei will isntall its templates so here are some common locations where Nuclei templates might be stored
common_paths=(
    "$HOME/nuclei-templates"           # Home directory
    "/usr/local/share/nuclei-templates" # Local share
    "/opt/nuclei-templates"             # Opt directory
)

# Check if these directories even exist
check_templates_dir() {
    if [[ -d $1 && -n $(ls $1) ]]; then
        echo "$1"
        return 0
    fi
    return 1
}

# Try to find the Nuclei templates directory
TEMPLATES_PATH=""
for path in "${common_paths[@]}"; do
    if TEMPLATES_PATH=$(check_templates_dir "$path"); then
        echo "Nuclei templates found at: $TEMPLATES_PATH"
        break
    fi
done

# Verify if a path was found
if [[ -z $TEMPLATES_PATH ]]; then
    echo "Unable to find Nuclei templates. Please ensure they are installed."
    exit 1
fi

# Now run the scan
sleep 2
echo "running nuclei scan..."
sleep 2
nuclei -l $live -t $TEMPLATES_PATH/http/cves,$TEMPLATES_PATH/http/vulnerabilities,$TEMPLATES_PATH/http/exposed-panels/,$TEMPLATES_PATH/http/misconfiguration/,$TEMPLATES_PATH/javascript/cves,$TEMPLATES_PATH/javascript/default-logins,$TEMPLATES_PATH/http/technologies,$TEMPLATES_PATH/http/misconfiguration,$TEMPLATES_PATH/javascript/enumeration/,$TEMPLATES_PATH/javascript/detection/ -c 5 -o $nuclei
echo ""
sleep 1
echo ""

######################################## Moving on to directory brute force ###################################
echo "starting directory brute forcing... (reqs are set to 2 reqs/ps to avoid being rate limited)"
echo ""
# create gospider directory
if [ ! -d "gospider" ]; then
    # Directory does not exist, so create it
    mkdir $domain_folder/gospider
    echo "Created directory 'gospider'"
else
    # Directory already exists
    echo ""
fi


# start with passive subdomain enum
echo "starting passive directory search..."
sleep 1
touch $dir_passive
chmod 664 $dir_passive
gau "$domain" | awk -F/ '{print $3"/"$4}' | sort -u > $dir_passive
echo "Directories and paths have been saved to $dir_passive"
sleep 1

# Go Spider spidering -c 5 limits reqs to 2 req/ps (this helps with ratelimiting)

echo "Starting gospider directory enumeration (this may take a while...)"
sleep 1
gospider -S $live -c 2 -d 0 --js --sitemap -v -q --other-source -o ./$domain_folder/gospider/
sleep 2
echo ""
echo "directory results can be found in ./$domain_folder/gospider/"
echo ""
sleep 1

### TO DO
# add google doring (will this be captcha'd?)
# add revealjs project
# add flags and a help page eventually
# add a flag to better view the data (db?)
# add more tools for more diverse results
# add support for more OS outside of ubuntu (install.sh)
# convert some of the code to golang



# Recon Improvements
## left off at cloud recon -- need to add that and move on
# Fix the asn_ip findings (just parse the reg asn file for only the ip)
# fix apex domains (save a copy with only the domains)
# clean up useless files
