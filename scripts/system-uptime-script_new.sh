#!/bin/bash

log_file="/tmp/uptime-report.log"
uptime_file="/tmp/uptime-report.out"
error_file="/tmp/uptime-report-errors.log"

# Function to log messages with timestamps
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

log "Starting server uptime check..."

# Read server hostnames or IP addresses from /tmp/servers.txt
upserver=$(for server in $(cat /tmp/servers.txt)
do
    # Use ssh to check the uptime of the server
    if ssh "$server" 'uptime' &> /dev/null; then
        uptime_output=$(ssh "$server" 'uptime')
        echo -n "$(date +'%Y-%m-%d %H:%M:%S') - $server: " >> "$uptime_file"
        echo "$uptime_output" | awk '{print $3,$4}' | sed 's/,//' >> "$uptime_file"
    else
        log "Failed to get uptime for $server."
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Failed to get uptime for $server." >> "$error_file"
    fi
done)

# Check if any errors occurred
if [ -s "$error_file" ]; then
    log "Errors occurred during uptime checks. See $error_file for details."
else
    log "Server uptime check completed successfully."
fi

# Display the uptime report
if [ -s "$uptime_file" ]; then
    column -t < "$uptime_file"
else
    log "No servers were reachable or provided uptime information."
fi

