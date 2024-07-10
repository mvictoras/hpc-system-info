#!/bin/bash

# Function to get GPU utilization
get_gpu_utilization() {
  nvidia-smi --query-gpu=utilization.gpu,memory.free,memory.used,utilization.memory --format=csv,nounits,noheader | paste -sd, - | tr -d ' '
}

# Function to get CPU utilization
get_cpu_utilization() {
  mpstat -P ALL 1 1 | awk '/CPU/ {next} /^Average/ {print $3}' | paste -sd, -
}

# Function to generate the CPU header
generate_cpu_header() {
  mpstat -P ALL 1 1 | awk '/CPU/ {next} /^Average/ {print "core_" $2}' | paste -sd, -
}

# Function to generate the GPU header
generate_gpu_header() {
  NUMBER_OF_GPUS=$(nvidia-smi --query-gpu=utilization.gpu,memory.free,memory.used,utilization.memory --format=csv,nounits,noheader | wc -l)
  GPU_HEADER=""
  for i in $(seq 1 ${NUMBER_OF_GPUS})
  do
    GPU_HEADER+="GPU_${i}_UTIL,GPU_${i}_MEM_FREE,GPU_${i}_MEM_USED,GPU_${i}_MEM_UTIL,"
  done
  # Remove the trailing comma and space
  GPU_HEADER=${GPU_HEADER%,}
  echo "${GPU_HEADER}"
}

# Function to get memory usage
get_memory_usage() {
    free -m | awk '/Mem:/ {print $3","$4}'
}

# CSV filename based on rank
RANK=$(hostname)
CSV_FILENAME="system_info_rank_${RANK}.csv"

CPU_HEADER=$(generate_cpu_header)
GPU_HEADER=$(generate_gpu_header)
# Write header to CSV file
echo "Timestamp,${GPU_HEADER},${CPU_HEADER},Memory_Used,Memory_Free" > $CSV_FILENAME

# Infinite loop to collect data every minute
while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    GPU_UTILIZATION=$(get_gpu_utilization)
    CPU_UTILIZATION=$(get_cpu_utilization)
    MEMORY_USAGE=$(get_memory_usage)
    
    # Combine all data into a CSV row
    CSV_ROW="$TIMESTAMP,$GPU_UTILIZATION,$CPU_UTILIZATION,$MEMORY_USAGE"
    
    # Append the row to the CSV file
    echo $CSV_ROW >> $CSV_FILENAME
    
    # Wait for one minute
    sleep 60
done
