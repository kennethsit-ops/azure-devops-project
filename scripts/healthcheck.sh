#!/usr/bin/env bash

set -u 

print_header() {
    local HOSTNAME=$(hostname)
    local CURRENT_USER=$(whoami)
    local CURRENT_TIME=$(date)
    local IP_ADDRESS=$(hostname -I | awk '{print $1}')
    echo "====================================="
    echo "VM Health Check"
    echo "====================================="
    echo
    echo "Hostname      : $HOSTNAME"
    echo "Current user  : $CURRENT_USER"
    echo "Date          : $CURRENT_TIME"
    echo "Private IP    : $IP_ADDRESS"
}

check_command() {
    local command=$1
    if command -v "$command" &> /dev/null; then
        echo "$command is installed"
    else
        echo "$command is not installed"
    fi
    echo
}



main() {
    print_header
    echo "-------------------------------------"
    check_command git
    check_command docker
    check_command terraform
    check_command az    
}

main