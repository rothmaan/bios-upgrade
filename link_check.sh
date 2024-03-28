#!/bin/bash

# Define team interfaces in an associative array
declare -A teams
teams[team0]="eth0 eth1"
teams[team1]="eth4 eth6"
teams[team2]="eth6 eth7"

# Loop through team interfaces team0 to team2
for team in "${!teams[@]}"; do
    echo "Checking link summary for $team"

    # Retrieve and list all interfaces for the current team
    for intf in ${teams[$team]}; do
        # Use ip link to get the link status
        link_status=$(ip link show $intf | awk '/state/ {print $9}')
        
        # Display interface and its link status
        if [[ "$link_status" == "UP" ]]; then
            echo "$intf is UP"
        else
            echo "$intf is DOWN or NOT PRESENT"
        fi
    done

    echo "--------------------------------"
done
