#!/bin/bash

# this is the vuln scanner with nuclei

# pass $domain flag from main
domain=$1

# set PATH

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
export GOPATH=$HOME/go

# Source the configuration file
source ./src/config.sh


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
nuclei -l $live -t $TEMPLATES_PATH -o $nuclei
