#!/bin/bash

# Define the output file
output_file="/var/tmp/links_down"

# Loop through team interfaces team0 to team2
for team in team0 team1 team2; do
    echo "Checking status for $team:" >> $output_file
    # Get current date and time
    current_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Use teamdctl to list interfaces part of the team
    interfaces=$(teamdctl $team state dump | grep -oP '"ifname": "\K[^"]+')
    
    # Flag to track if all interfaces are up
    all_up=true

    # Loop through each interface found
    for intf in $interfaces; do
        # Use ip link to check the operational state of the interface
        op_state=$(ip link show $intf | awk '/state/ {print $9}')
        if [[ "$op_state" != "UP" ]]; then
            echo "$current_date: $intf in $team is down" >> $output_file
            all_up=false
            # If an interface is down, no need to check uptime
            continue
        fi
    done

    if $all_up; then
        echo "$current_date: All interfaces in $team appear to be up" >> $output_file
    fi

    echo "--------------------------------" >> $output_file
done
