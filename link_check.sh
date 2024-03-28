#!/bin/bash

# Define the interfaces and their respective teams in an associative array
declare -A teams
teams[team0]="eth0 eth1"
teams[team1]="eth4 eth6"
teams[team2]="eth6 eth7"

# Loop through each team
for team in "${!teams[@]}"; do
    echo "Checking link summary for $team"
    # Iterate through each interface in the current team
    for intf in ${teams[$team]}; do
        # Extract the operational state of the interface
        op_state=$(ip link show "$intf" | grep -oP '(?<=state )[^ ]+')

        # Check if the state is UP and print the interface name along with its status
        if [[ "$op_state" == "UP" ]]; then
            echo "$intf is UP"
        else
            echo "$intf is DOWN"
        fi
    done
    echo "--------------------------------"
done
