#!/bin/bash

# Check if an argument is provided
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/log/directory"
  exit 1
fi

REMOTE_LOG_DIRECTORY="$1/logs"

# File containing hostnames
HOSTS_FILE="${PBS_NODEFILE}"

# Command to run on each remote host
REMOTE_COMMAND="mkdir -p ${REMOTE_LOG_DIRECTORY}; cd ${REMOTE_LOG_DIRECTORY}; nohup ${GRAND}/ISAV24/scripts/collect_system_info.sh > /dev/null 2>&1 &"

# Loop through each hostname in the file
for HOSTNAME in $(cat "$HOSTS_FILE"); do
  echo "Starting collection of stats on $HOSTNAME"
  ssh "$HOSTNAME" "$REMOTE_COMMAND" || true
done
