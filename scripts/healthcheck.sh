#!/usr/bin/env bash

HOSTNAME=$(hostname)
CURRENT_USER=$(whoami)
CURRENT_TIME=$(date)
IP_ADDRESS=$(hostname -I | awk '{print $1}')


set -u 
echo "====================================="
echo "VM Health Check"
echo "====================================="

echo "Hostname      : $HOSTNAME"
echo "Current user  : $CURRENT_USER"
echo "Date          : $CURRENT_TIME"
echo "Private IP    : $IP_ADDRESS"
