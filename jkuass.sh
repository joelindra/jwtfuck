#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to decode base64 URL
base64_url_decode() {
    local input=${1//-/+}
    input=${input//_//}
    local mod4=$(( ${#input} % 4 ))
    if [ $mod4 -eq 2 ]; then
        input="${input}=="
    elif [ $mod4 -eq 3 ]; then
        input="${input}="
    fi
    echo "$input" | base64 -d
}

# Function to fetch public key from jku
fetch_jku_key() {
    local jku_url=$1
    local public_key=$(curl -s "$jku_url" | jq -r '.keys[0].x5c[0]' | base64 -d)
    if [ -z "$public_key" ]; then
        echo -e "${RED}Failed to fetch public key from $jku_url.${NC}"
        exit 1
    fi
    echo "$public_key"
}

# Function to verify JWT with jku
verify_jwt_with_jku() {
    local token=$1

    local header=$(echo "$token" | cut -d "." -f1 | base64_url_decode | jq .)
    local jku=$(echo "$header" | jq -r '.jku')
    if [ -z "$jku" ]; then
        echo -e "${RED}No 'jku' header found in the JWT header.${NC}"
        exit 1
    fi

    local public_key=$(fetch_jku_key "$jku")
    echo -e "${GREEN}Fetched Public Key:${NC} $public_key"

    # Here you would use the public key to verify the token's signature
    # This step depends on the tool/language you use for verification
}

# Main function
main() {
    local verbose=false
    local token=""

    # Parse options
    while getopts ":i:vy" opt; do
        case $opt in
            i)
                token="$OPTARG"
                ;;
            v)
                verbose=true
                ;;
            y)
                verbose=true
                ;;
            \?)
                echo -e "${RED}Invalid option: -$OPTARG${NC}"
                exit 1
                ;;
        esac
    done

    # Check if token is provided
    if [ -z "$token" ]; then
        read -p "Enter JWT token: " token
    fi

    # Verbose output
    if [ "$verbose" = true ]; then
        echo -e "${GREEN}Verifying JWT with jku header...${NC}"
    fi

    verify_jwt_with_jku "$token"
}

# Execute main function with arguments
main "$@"
