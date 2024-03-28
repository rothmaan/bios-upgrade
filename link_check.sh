#!/bin/bash

# Define the output file
output_file="/var/tmp/links_down" # Path to the file where the script will log its output

# Define the interfaces for each team using an associative array
declare -A team_interfaces
team_interfaces[team0]="eth0 eth1"  # Interfaces eth0 and eth1 are part of team0
team_interfaces[team1]="eth4 eth5"  # Interfaces eth4 and eth5 are part of team1
team_interfaces[team2]="eth6 eth7"  # Interfaces eth6 and eth7 are part of team2

# Loop through each team defined in the associative array
for team in "${!team_interfaces[@]}"; do
    # Log the team being checked
    echo "Checking status for $team:"

    # Get current date and time
    current_date=$(date "+%Y-%m-%d %H:%M:%S") # Current system date and time for logging

    # Flag to keep track if all interfaces in the current team are up
    all_up=true

    # Iterate over each interface assigned to the current team
    for intf in ${team_interfaces[$team]}; do
        # Use ip link to check the operational state of the interface
        op_state=$(ip link show $intf | awk '/state/ {print $9}') # Extract the operational state of the interface
        if [[ "$op_state" != "UP" ]]; then
            # If interface is down, log it and set all_up to false
            echo "$current_date: $intf in $team is down"
            all_up=false
        else
            # Log that the interface is up
            echo "$current_date: $intf in $team is UP"
        fi
    done

    # If all interfaces in the team are up, log that as well
    if $all_up; then
        echo "$current_date: All interfaces in $team appear to be up"
    fi

    # Log a separator for readability
    echo "--------------------------------"
done
