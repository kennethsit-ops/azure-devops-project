#!/usr/bin/env bash

set -u 
HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)
CURRENT_TIME=$(date)
IP_ADDRESS=$(hostname -I | awk '{print $1}')

print_header() {

    echo "====================================="
    echo "VM Health Check"
    echo "====================================="
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