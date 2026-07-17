#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configuration
#######################################
TARGET="${1:-Local VM}"
LOGFILE="healthcheck.log"

COMMANDS=(
    git
    docker
    az
    terraform
    kubectl
)

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

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

#######################################
# Main
#######################################
main() {

    log INFO "Starting health check"

    print_header

    for command in "${COMMANDS[@]}"
    do
        check_command "$command"
    done

    log INFO "Health check completed"
}

main