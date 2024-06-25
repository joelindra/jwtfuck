#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run a script with colorized output
run_script() {
    script_name="$1"
    echo -e "${YELLOW}Running ${script_name}...${NC}"
    ./"${script_name}"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}${script_name} executed successfully.${NC}"
    else
        echo -e "${RED}Error executing ${script_name}.${NC}"
    fi
}

# Main menu function
main_menu() {
    clear
    echo -e "${GREEN}Created By Anonre | Joel Indra${NC}"
    echo -e "${YELLOW}Please select a script to run:${NC}"
    echo -e "1. JWT HMAC BruteForce"
    echo -e "2. JWT JKU Assessment"
    echo -e "3. JWT Spoofing"
    echo -e "4. JWT Reveal Kid"
    echo -e "0. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) run_script hmacbrute.sh ;;
        2) run_script jkuass.sh ;;
        3) run_script jwtspoof.sh ;;
        4) run_script revealkid.sh ;;
        0) echo -e "${YELLOW}Exiting Script Runner.${NC}" && exit ;;
        *) echo -e "${RED}Invalid choice.${NC}" && sleep 2 ;;
    esac
}

# Loop for continuous execution
while true; do
    main_menu
done
