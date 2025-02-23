#!/bin/bash

# Define variables
INTERFACE="enx287bd2ced43f" # Replace with device id (run ip link on the cmd line to find)
ROUTER_IP="192.168.86.1" # Replace with your router ip
LOG_FILE="/var/log/network_checker.log"

# Function to log messages with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the interface is up
if ip link show "$INTERFACE" | grep -q "state UP"; then
    # Ping the router
    if ! ping -c 1 -W 2 "$ROUTER_IP" > /dev/null 2>&1; then
        log_message "Ping to $ROUTER_IP failed. Restarting interface $INTERFACE."
        sudo ip link set "$INTERFACE" down
        sleep 1  # Short delay to ensure the interface goes down fully
        sudo ip link set "$INTERFACE" up
        log_message "Interface $INTERFACE restarted."
    else
        log_message "Ping to $ROUTER_IP successful. No action needed."
    fi
else
    log_message "Interface $INTERFACE is down. Bringing it up."
    sudo ip link set "$INTERFACE" up
    log_message "Interface $INTERFACE brought up."
fi
