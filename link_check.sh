#!/bin/bash

# Define the team names
teams=("team0" "team1" "team2")

# Loop through each team
for team in "${teams[@]}"; do
    echo "Checking link summary for $team"
    
    # Use teamdctl to get the list of interfaces in the team
    # This approach assumes a simple enough output format to use grep and awk for extraction
    interfaces=$(teamdctl $team state view | grep -oP '"ifname": "\K[^"]+')

    for intf in $interfaces; do
        # Extract the operational state of the interface
        op_state=$(ip link show "$intf" | grep -oP '(?<=state )[^ ]+')

        # Print the interface name and its status
        if [[ "$op_state" == "UP" ]]; then
            echo "$intf is UP"
        else
            echo "$intf is DOWN"
        fi
    done
    
    echo "--------------------------------"
done
