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


check_azure_login_and_subscription() {
    local subscription_name
    local subscription_id

    if ! az account show &> /dev/null
    then
        report_result "Azure Login" FAIL "not logged in; run az login"
        return
    fi

    current_subscription_name=$(az account show --query "name" -o tsv)
    current_subscription_id=$(az account show --query "id" -o tsv)

    if [[ "$current_subscription_id" == "$AZURE_SUBSCRIPTION_ID" ]]
    then 
        report_result "Azure Subscription" PASS "Logged into correct subscription: $current_subscription_name ($current_subscription_id)"
    else
        report_result "Azure Subscription" WARN "Logged into wrong subscription: $current_subscription_name ($current_subscription_id), expected: $AZURE_SUBSCRIPTION_NAME ($AZURE_SUBSCRIPTION_ID)"
    fi
}


check_azure_resource_group() {
    local exists
    local location

    exists=$(az group exists --name "$AZURE_RESOURCE_GROUP_NAME")

    if [[ "$exists" != "true" ]]
    then
        report_result "Azure Resource Group" FAIL "Resource group $AZURE_RESOURCE_GROUP_NAME does not exist"
        return
    fi

    location=$(az group show --name "$AZURE_RESOURCE_GROUP_NAME" --query "location" -o tsv)
    report_result "Resource Group" PASS "Resource group $AZURE_RESOURCE_GROUP_NAME exists in location $location"

}


check_azure_vms()
{
    local vm_data
    local vm_name
    local power_state
    local vm_count=0

    if ! vm_data=$(az vm list --resource-group "$AZURE_RESOURCE_GROUP" --show-details --query "[].[name, powerState]" --output tsv)
    then
        report_result "Azure VM" FAIL "Unable to retrieve VM information"
        return
    fi

    if [[ -z "$vm_data" ]]
    then
        report_result "Azure VM" WARN "No VMs found in resource group $AZURE_RESOURCE_GROUP"
        return
    fi

    while IFS=$'\t' read -r vm_name power_state
    do 
        ((vm_count += 1))

        case "$power_state" in
            "VM running")
                report_result "Azure VM: $vm_name" PASS "($power_state)"
                ;;
            "VM stopped"|"VM deallocated")
                report_result "Azure VM: $vm_name" WARN "($power_state)"
                ;;
            *)
                report_result "Azure VM: $vm_name" FAIL "(${power_state:-unknown state})"
                ;;
        esac
    done <<< "$vm_data"

    log INFO "Checked $vm_count VMs in resource group $AZURE_RESOURCE_GROUP"

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

    printf "\nAzure checks\n"
    check_azure_login_and_subscription
    check_azure_resource_group
    check_azure_vms

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