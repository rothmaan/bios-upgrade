#!/bin/bash

# Define the output file
output_file="/var/tmp/links_down" # Output file path

# Define the interfaces for each team using an associative array
declare -A team_interfaces
team_interfaces[team0]="eth0 eth1"  # Team0 member interfaces
team_interfaces[team1]="eth4 eth5"  # Team1 member interfaces
team_interfaces[team2]="eth6 eth7"  # Team2 member interfaces

# Loop through each team defined in the associative array
for team in "${!team_interfaces[@]}"; do
    # Get current date and time
    current_date=$(date "+%Y-%m-%d %H:%M:%S")

    # Check if the team interface itself is up
    team_state=$(ip link show $team | awk '/state/ {print $9}')
    if [[ "$team_state" == "UP" ]]; then
        echo "$current_date: $team interface is UP" >> $output_file
    else
        echo "$current_date: $team interface is DOWN" >> $output_file
        # If the team interface is down, no need to check individual interfaces
        continue
    fi

    # Flag to keep track if all interfaces in the current team are up
    all_up=true

    # Iterate over each interface assigned to the current team
    for intf in ${team_interfaces[$team]}; do
        # Use ip link to check the operational state of the interface
        op_state=$(ip link show $intf | awk '/state/ {print $9}')
        if [[ "$op_state" != "UP" ]]; then
            echo "$current_date: $intf in $team is down" >> $output_file
            all_up=false
        else
            echo "$current_date: $intf in $team is UP" >> $output_file
        fi
    done

    if $all_up; then
        echo "$current_date: All interfaces in $team appear to be up" >> $output_file
    fi

    echo "--------------------------------" >> $output_file
done
