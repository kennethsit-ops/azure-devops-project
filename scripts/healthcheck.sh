#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configuration
#######################################
TARGET="${1:-Local VM}"

# Define the script directory and project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TOOLKIT_CONF="$PROJECT_DIR/config/toolkit.conf"
COMMAND_FILE="$PROJECT_DIR/config/commands.conf"

# Load toolkit configuration
if [[ -f "$TOOLKIT_CONF" ]]
then
    # shellcheck source=/dev/null
    source "$TOOLKIT_CONF"
else
    printf "%s\n" "Config file not found: $TOOLKIT_CONF" >&2
    exit 1
fi

# Default logging and threshold values
LOG_DIR="${LOG_DIR:-logs}"
LOG_FILE="${LOG_FILE:-healthcheck.log}"
DISK_WARN_THRESHOLD="${DISK_WARN_THRESHOLD:-80}"
DISK_FAIL_THRESHOLD="${DISK_FAIL_THRESHOLD:-90}"
MEMORY_WARN_THRESHOLD="${MEMORY_WARN_THRESHOLD:-80}"
MEMORY_FAIL_THRESHOLD="${MEMORY_FAIL_THRESHOLD:-90}"

if [[ "$LOG_FILE" = /* ]]
then
    LOG_PATH="$LOG_FILE"
else
    LOG_PATH="$PROJECT_DIR/${LOG_DIR%/}/$LOG_FILE"
fi
mkdir -p "$(dirname "$LOG_PATH")" # Create logs directory if it doesn't exist

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

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
        >> "$LOG_PATH"
}


report_result () {
    local check_name="$1"
    local status="$2"
    local details="${3:-}"
    local detail_text=""

    if [[ -n "$details" ]]
    then
        detail_text=" $details"
    fi

    case "$status" in
        PASS)
            ((PASS_COUNT+=1))
            log INFO "$check_name: PASS$detail_text"
            printf "%-20s ${GREEN}PASS${RESET}%s\n" "$check_name" "$detail_text"
            ;;
        WARN)
            ((WARN_COUNT+=1))
            log WARN "$check_name: WARN$detail_text"
            printf "%-20s ${YELLOW}WARN${RESET}%s\n" "$check_name" "$detail_text"
            ;;
        FAIL)
            ((FAIL_COUNT+=1))
            log ERROR "$check_name: FAIL$detail_text"
            printf "%-20s ${RED}FAIL${RESET}%s\n" "$check_name" "$detail_text"
            ;;
        *)
            ((FAIL_COUNT+=1))
            log ERROR "$check_name: Unknown status '$status'$detail_text"
            printf "%-20s ${RED}FAIL${RESET} (Unknown: %s)\n" "$check_name" "$details"
            ;;
    esac 
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
        report_result "$command" PASS
    else
        report_result "$command" FAIL "command not found"
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

    while IFS= read -r command || [[ -n "$command" ]]
    do
        [[ -z "$command" ]] && continue   # Skip empty lines
        [[ "$command" == \#* ]] && continue # Skip comments
        
        check_command "$command"
    done < "$COMMAND_FILE"
}

check_disk()
{
    local mount_point="${1:-/}"
    local usage

    usage=$(df -h "$mount_point" |
        awk 'NR==2 {gsub("%", "", $5); print $5}')

    if [[ -z "$usage" || ! "$usage" =~ ^[0-9]+$ ]]
    then
        report_result "Disk $mount_point" FAIL "unable to determine usage"
        return
    fi

    if (( usage < DISK_WARN_THRESHOLD ))
    then
        report_result "Disk $mount_point" PASS "(${usage}% used)"
    elif (( usage < DISK_FAIL_THRESHOLD ))
    then
        report_result "Disk $mount_point" WARN "(${usage}% used)"
    else
        report_result "Disk $mount_point" FAIL "(${usage}% used)"
    fi
}


check_memory()
{
    local usage

    usage=$(free | awk '
        /^Mem:/ {   # Get the line starting with "Mem:"
            usage = (($2 - $7) / $2) * 100
            printf "%.0f\n", usage
        }')

    if [[ -z "$usage" || ! "$usage" =~ ^[0-9]+$ ]]
    then
        report_result "Memory" FAIL "unable to determine usage"
        return
    fi

    if (( usage < MEMORY_WARN_THRESHOLD ))
    then
        report_result "Memory" PASS "(${usage}% used)"
    elif (( usage < MEMORY_FAIL_THRESHOLD ))
    then
        report_result "Memory" WARN "(${usage}% used)"
    else
        report_result "Memory" FAIL "(${usage}% used)"
    fi
}


check_cpu_load()
{
    local cpuload
    local cores

    cpuload=$(awk '{print $1}' /proc/loadavg)
    cores=$(nproc)

    local status

    status=$(awk -v load_value="$cpuload" -v cores="$cores" '
    BEGIN {
        if (load_value < cores * 0.8)
            print "PASS"
        else if (load_value < cores) 
            print "WARN"
        else
            print "FAIL"
    }')

    report_result "CPU Load" "$status" "(cpuload ${cpuload}, cores ${cores})"
}


print_summary() {
    printf "\n"
    printf "=====================================\n"
    printf "Health Check Summary\n"
    printf "=====================================\n"
    printf "\n%-10s %d\n" "Passed:" "$PASS_COUNT"
    printf "%-10s %d\n" "Warnings:" "$WARN_COUNT"
    printf "%-10s %d\n" "Failed:" "$FAIL_COUNT"
}


#######################################
# Main
#######################################
main() {

    log INFO "Starting health check"

    print_header

    check_commands_from_file

    printf "\nLocal system checks\n"
    check_disk "/"

    check_memory

    check_cpu_load

    print_summary

    if [[ $FAIL_COUNT -eq 0 ]]
    then
        log INFO "Health check completed successfully"
        exit 0
    else
        log ERROR "Health check completed with failures"
        exit 1
    fi
}

main