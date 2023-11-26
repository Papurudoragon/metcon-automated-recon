#!/bin/bash

# pass $domain flag from main
domain=$1
domain_folder="${domain%.com}"

# Source the configuration file
source ./src/config.sh

# github token path
TOKEN_FILE_PATH="$HOME/.git_access_key/access_key"

# Function to provide instructions for creating the token file
create_token_instructions() {
    echo "GitHub token not found."
    echo "Please create a file at $TOKEN_FILE_PATH with your GitHub token."
    echo "You can do this with the following commands:"
    echo "  mkdir -p ~/.git_access_key"
    echo "  echo 'your_github_key_here' > $TOKEN_FILE_PATH"
    echo "  chmod 600 $TOKEN_FILE_PATH"
    echo "Replace 'your_github_key_here' with your actual GitHub token."
}


# Check if the token file exists and read the token
if [ -f "$TOKEN_FILE_PATH" ]; then
    GITHUB_TOKEN=$(cat "$TOKEN_FILE_PATH")
else
    create_token_instructions
    echo "skipping the github dorking step......"
    sleep 5
    exit 1 # This should continue the code instead of exiting if no token was found.
fi



# Array of GitHub dorks to use
declare -a dorks=(
    "filename:.env DB_USERNAME DB_PASSWORD"
    "filename:docker-compose.yml MYSQL_ROOT_PASSWORD"
    "filename:.htpasswd"
    "filename:.git-credentials"
    "path:/root/ filename:wp-config.php"
    "filename:.bash_history"
    "filename:id_rsa or filename:id_dsa"
    "filename:.npmrc _auth"
    "filename:.dockercfg auth"
    "extension:pem private"
    "filename:.pgpass"
    "filename:.s3cfg"
    "filename:wp-config.php"
    "filename:.travis.yml AWS_ACCESS_KEY_ID"
    "filename:.bashrc password"
    "filename:.bash_profile aws"
    "HEROKU_API_KEY language:json"
    "filename:.netrc password"
    "filename:_netrc password"
    "filename:hub oauth_token"
    "filename:robomongo.json"
    "filename:.npmrc NPM_TOKEN"
    "filename:.eslintrc AWS_SECRET_ACCESS_KEY"
    "filename:.travis.yml secure"
    "HOMEBREW_GITHUB_API_TOKEN language:shell"
    "filename:.bashrc mailchimp"
    "filename:.gitconfig token"
    "filename:.bashrc stripe"
    "filename:.bash_profile heroku"
    "filename:credentials aws_access_key_id"
    "filename:config irc_pass"
    "extension:sql mysql dump"
    "extension:sql site:github.com"
    "filename:dump.sql"
    "filename:backup.zip"
    "filename:backup.tar.gz"
    "filename:.sql.gz"
    "filename:credentials.json"
    "extension:json api_key"
    "extension:json api_secret"
    "filename:.pgpass"
)

####----- This needs to be updated

# # Function to perform GitHub dorking
# perform_github_dorking() {
#     local domain=$1
#     for dork in "${dorks[@]}"; do
#         echo "Searching for: $dork in domain: $domain"

#         # Actual GitHub API search command
#         # This uses 'curl' to make a request to the GitHub API
#         # github token is found in ~./git_access_Token/access_token ---> this needs to be manually added.
#         local search_result=$(curl -H "Authorization: token $GITHUB_TOKEN" -s "https://api.github.com/search/code?q=${dork}+in:${domain}" >> $git_dorking)
#     done
# }

# # Perform dorking for a given domain
# perform_github_dorking "$domain"

# # Iterate over each dork and perform the search
# for dork in "${DORKS[@]}"; do
#     perform_dorking "$dork"
# done
