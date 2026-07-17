#!/usr/bin/env bash

set -u 

print_header() {
    local HOSTNAME=$(hostname)
    local CURRENT_USER=$(whoami)
    local CURRENT_TIME=$(date)
    local IP_ADDRESS=$(hostname -I | awk '{print $1}')
    printf "\n"
    printf "=====================================\n"
    printf "VM Health Check\n"
    printf "=====================================\n\n"
    printf "Hostname      : %s\n" "$HOSTNAME"
    printf "Current user  : %s\n" "$CURRENT_USER"
    printf "Date          : %s\n" "$CURRENT_TIME"
    printf "Private IP    : %s\n" "$IP_ADDRESS"
}

check_command() {
    local command=$1
    if command -v "$command" &> /dev/null
    then
        printf "%-20s PASS\n" "$command"
    else
        printf "%-20s FAIL\n" "$command"
    fi
}
main() {
    print_header
    printf "-------------------------------------\n"

    for command in git docker terraform az
    do
        check_command "$command"
    done
}

main


