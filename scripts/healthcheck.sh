#!/usr/bin/env bash

set -u 
echo "====================================="
echo "VM Health Check"
echo "====================================="

echo "Hostname: $(hostname)"
echo "Current user: $(whoami)"
echo "Date: $(date)"
echo "Private IP: $(hostname -I | awk '{print $1}')"