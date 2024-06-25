#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to encode base64 URL
base64_url_encode() {
    local input=$1
    local encoded=$(echo -n "$input" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n')
    echo "$encoded"
}

# Function to embed new public key in the JWT header
embed_new_public_key() {
    local token=$1
    local new_key=$2

    local header=$(echo $token | cut -d "." -f1 | base64 -d | jq --arg key "$new_key" '. + {newKey: $key}' | base64_url_encode)
    local payload=$(echo $token | cut -d "." -f2)
    local signature=$(echo $token | cut -d "." -f3)

    local new_token="${header}.${payload}.${signature}"
    echo "${new_token#*.}"  # Remove the leading dot
}

# Function to generate a new public key
generate_public_key() {
    local new_key=$(openssl rand -base64 32)
    echo "$new_key"
}

# Main function
main() {
    local token=""
    local manual_key=""
    local verbose="n"
    local path=""

    # User input for JWT token
    read -p "Enter the JWT token: " token

    # User input for manual key or auto-generate
    read -p "Enter 'm' to provide a new public key manually, or 'a' to generate one automatically: " choice
    case "$choice" in
        m|M)
            read -p "Enter the new public key: " manual_key
            ;;
        a|A)
            manual_key=$(generate_public_key)
            ;;
        *)
            echo -e "${RED}Error: Invalid choice.${NC}"
            exit 1
            ;;
    esac

    # User input for path if specified
    read -p "Enter the output path to save the new JWT (leave empty to skip): " path

    # Verbose mode toggle
    read -p "Enable verbose mode (y/n)? " verbose_choice
    case "$verbose_choice" in
        y|Y)
            verbose="y"
            ;;
        n|N)
            verbose="n"
            ;;
        *)
            echo -e "${RED}Error: Invalid choice.${NC}"
            exit 1
            ;;
    esac

    if [ "$verbose" = "y" ]; then
        echo "Verbose mode enabled."
        echo "Token: $token"
        echo "Manual Key: $manual_key"
        echo "Path: $path"
    fi

    local new_jwt=$(embed_new_public_key "$token" "$manual_key")
    echo -e "${GREEN}New JWT:${NC} $new_jwt"

    if [ -n "$path" ]; then
        echo "Writing to $path..."
        echo "$new_jwt" > "$path"
        echo "Done."
    fi
}

# Execute main function
main
