#!/bin/bash

# File containing hostnames
HOSTS_FILE="${PBS_NODEFILE}"

# Command to run on each remote host
REMOTE_COMMAND="killall collect_system_info.sh"

# Loop through each hostname in the file
for HOSTNAME in $(cat "$HOSTS_FILE"); do
  echo "Killing stats on $HOSTNAME"
  ssh "$HOSTNAME" "$REMOTE_COMMAND" || true
done
