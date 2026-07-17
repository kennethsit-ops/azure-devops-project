#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configuration
#######################################
TARGET="${1:-Local VM}"


# Define the script directory and project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMMAND_FILE="$PROJECT_DIR/config/commands.conf"
LOG_FILE="$PROJECT_DIR/logs/healthcheck.log"
mkdir -p "$(dirname "$LOG_FILE")" # Create logs directory if it doesn't exist

# Define color codes for output
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

#Logging function
log () {
    local LEVEL="$1"
    local MESSAGE="$2"
    printf "%s [%s] %s\n" \
        "$(date '+%Y-%m-%d %H:%M:%S')" \
        "$LEVEL" \
        "$MESSAGE" \
        >> "$LOGFILE"
}

#######################################
# Display header
#######################################
print_header() {
    local CURRENT_USER=$(whoami)
    local CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    local IP_ADDRESS=$(hostname -I | awk '{print $1}')

    printf "\n"
    printf "=====================================\n"
    printf "VM Health Check\n"
    printf "=====================================\n\n"
    printf "Target        : %s\n" "$TARGET"
    printf "Current user  : %s\n" "$CURRENT_USER"
    printf "Date          : %s\n" "$CURRENT_TIME"
    printf "IP Address    : %s\n" "$IP_ADDRESS"
}

#######################################
# Check whether a command exists
#######################################
check_command() {
    local command=$1
    if command -v "$command" &> /dev/null
    then
        log INFO "$(printf "%-20s PASS" "$command")"
        printf "%-20s ${GREEN}PASS${RESET}\n" "$command"
    else
        log ERROR "$(printf "%-20s FAIL" "$command")"
        printf "%-20s ${RED}FAIL${RESET}\n" "$command"
    fi
}


#############################################################
# Check whether a command exists using a config file
#############################################################
check_commands_from_file() {
    if [[ ! -f "$COMMAND_FILE" ]] 
    then
        log ERROR "Config file not found: $COMMAND_FILE"
        printf "${RED}Config file not found: $COMMAND_FILE${RESET}\n"
        exit 1
    fi

    while read -r command
    do
        [[ -z "$command"]] && continue   # Skip empty lines
        [[ "$command" == \#* ]] && continue # Skip comments
        
        check_command "$command"
    done < "$COMMAND_FILE"
}



#######################################
# Main
#######################################
main() {

    log INFO "Starting health check"

    print_header

#    for command in "${COMMANDS[@]}"
#    do
#        check_command "$command"
#    done

    check_commands_from_file

    log INFO "Health check completed"
}

main