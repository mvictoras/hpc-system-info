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
# Function to calculate averages
calculate_averages() {
	arrays=("$@")
  num_values=$(echo ${arrays[0]} | awk -F, '{print NF}')
  sums=($(for i in $(seq 1 $num_values); do echo 0; done))
  counts=0

  for array in "${arrays[@]}"; do
    IFS=',' read -r -a values <<< "$array"
    for i in $(seq 0 $((${#values[@]} - 1))); do
      sums[$i]=$(echo "${sums[$i]} + ${values[$i]}" | bc)
    done
    counts=$((counts + 1))
  done

  averages=()
  for sum in "${sums[@]}"; do
    averages+=($(echo "scale=2; $sum / $counts" | bc | awk '{printf "%.2f", $0}'))
  done

  echo "${averages[@]}" | tr ' ' ','
}

# CSV filename based on rank
RANK=${PMI_RANK}
CSV_FILENAME="system_info_rank_${RANK}.csv"

CPU_HEADER=$(generate_cpu_header)
GPU_HEADER=$(generate_gpu_header)
# Write header to CSV file
echo "Timestamp,${GPU_HEADER},${CPU_HEADER},Memory_Used,Memory_Free" > $CSV_FILENAME

# Get start time
START_TIME=$(date +%s)
GPU_UTILS=()
CPU_UTILS=()
MEMORY_UTILS=()


# Infinite loop to collect data every minute
while true; do

  # Get current time and calculate elapsed time
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

  GPU_UTILIZATION=$(get_gpu_utilization)
  CPU_UTILIZATION=$(get_cpu_utilization)
  MEMORY_USAGE=$(get_memory_usage)

  GPU_UTILS+=("$GPU_UTILIZATION")
  CPU_UTILS+=("$CPU_UTILIZATION")
  MEMORY_UTILS+=("$MEMORY_USAGE")

  # Check if elapsed time is greater than or equal to 60 seconds
  if [ $ELAPSED_TIME -ge 60 ]; then
    AVG_GPU_UTIL=$(calculate_averages "${GPU_UTILS[@]}")
    AVG_CPU_UTIL=$(calculate_averages "${CPU_UTILS[@]}")
    AVG_MEMORY_USAGE=$(calculate_averages "${MEMORY_UTILS[@]}")

    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    # Combine all data into a CSV row
    CSV_ROW="$TIMESTAMP,$AVG_GPU_UTIL,$AVG_CPU_UTIL,$AVG_MEMORY_USAGE"

    # Append the row to the CSV file
    echo $CSV_ROW >> $CSV_FILENAME

    # Reset arrays and start time
    GPU_UTILIZATIONS=()
    CPU_UTILIZATIONS=()
    MEMORY_UTILS=()
    START_TIME=$CURRENT_TIME
  fi
done
