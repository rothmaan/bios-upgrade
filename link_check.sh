
#!/bin/bash

# Define the output file
output_file="/var/tmp/links_down"

# Loop through team interfaces team0 to team2
for team in team0 team1 team2; do
    echo "Checking status for $team:" >> $output_file
    # Get current date and time
    current_date=$(date "+%Y-%m-%d %H:%M:%S")

    # Initially assume all interfaces are up
    all_up=true

    # Check each interface in the team
    for intf in $(teamdctl $team state view | jq -r '.ports | keys[]'); do
        # Check the operational state of the interface
        op_state=$(cat /sys/class/net/$intf/operstate)
        if [[ "$op_state" == "down" ]]; then
            all_up=false
            echo "$current_date: $intf in $team is down" >> $output_file
            # When the interface is down, skip uptime calculation
            continue
        fi

        # Calculate the interface's uptime
        last_changed=$(cat /sys/class/net/$intf/statistics/rx_bytes)
        intf_uptime_seconds=$(echo "$last_changed / 100" | bc)
        intf_uptime=$(date -ud "@$intf_uptime_seconds" +'%H hours, %M minutes, %S seconds')

        echo "$current_date: $intf in $team is up. Uptime: $intf_uptime" >> $output_file
    done

    if $all_up; then
        echo "$current_date: All interfaces in $team appear to be up" >> $output_file
    fi

    echo "--------------------------------" >> $output_file
done

