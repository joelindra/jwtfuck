#!/bin/bash

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

# Function to find key by kid
find_key_by_kid() {
    local kid=$1
    local key_database=$2

    jq -r --arg kid "$kid" '.keys[] | select(.kid==$kid) | .x5c[0]' "$key_database" | base64 -d
}

# Function to generate a key database
generate_key_database() {
    local output_file=$1
    local keys=()

    # Generate keys - Example keys
    keys+=("kid1:x5c1")
    keys+=("kid2:x5c2")
    keys+=("kid3:x5c3")
    keys+=("kid4:x5c4")  # Additional key
    keys+=("kid5:x5c5")  # Additional key
    keys+=("kid6:x5c6")  # Additional key

    # Create JSON format
    echo "{ \"keys\": [" > "$output_file"
    for key in "${keys[@]}"; do
        local kid=$(echo "$key" | cut -d ":" -f1)
        local x5c=$(echo "$key" | cut -d ":" -f2)
        echo "{ \"kid\": \"$kid\", \"x5c\": [\"$x5c\"] }," >> "$output_file"
    done
    # Remove the last comma
    sed -i '$ s/.$//' "$output_file"
    echo "] }" >> "$output_file"

    echo -e "\e[32mKey database generated: $output_file\e[0m"
}

# Function to print colored messages
print_color() {
    local color=$1
    local message=$2
    local nc='\033[0m' # No Color
    echo -e "${color}${message}${nc}"
}

# Main function
main() {
    local red='\e[31m'
    local green='\e[32m'
    local yellow='\e[33m'
    local blue='\e[34m'

    local verbose_level=0
    local token=""
    local key_database="key_database.json"  # Default key database file

    if [ ! -f "$key_database" ]; then
        generate_key_database "$key_database"
    fi

    # User input for JWT token
    read -rp "Enter JWT token: " token

    # User input for custom key database file
    read -e -i "" -p "Enter custom key database file/ default [key_database_json]: " custom_key_db
    key_database="${custom_key_db:-$key_database}"

    # User input for verbose mode
    read -rp "Enable verbose mode? (y/n): " verbose_input
    case "$verbose_input" in
        [yY])
            verbose_level=1
            ;;
        *)
            verbose_level=0
            ;;
    esac

    if [ -z "$token" ]; then
        print_color "$red" "Usage: $0 [-v|-vv] <jwt-token>"
        exit 1
    fi

    if [ $verbose_level -ge 1 ]; then
        print_color "$blue" "Decoding JWT header..."
    fi
    local header=$(echo "$token" | cut -d "." -f1 | base64_url_decode | jq .)
    local kid=$(echo "$header" | jq -r '.kid')

    if [ $verbose_level -ge 1 ]; then
        print_color "$yellow" "kid: $kid"
        print_color "$blue" "Fetching key from the database..."
    fi
    local key=$(find_key_by_kid "$kid" "$key_database")

    if [ -n "$key" ]; then
        if [ $verbose_level -ge 1 ]; then
            print_color "$green" "Fetched Key: $key"
        else
            echo "$key"
        fi
    else
        print_color "$red" "Key not found for kid: $kid"
    fi
}

# Execute main function
main "$@"
