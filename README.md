# System Info Collection Script

This script collects GPU and CPU utilization data along with memory usage, averages the data every minute, and writes the results to a CSV file. It is designed to run on systems with NVIDIA GPUs and utilizes tools like `nvidia-smi`, `mpstat`, and `free` to gather the necessary data.

## Motivation

The primary motivation for this script is to use it in High-Performance Computing (HPC) environments. It runs in the background while simulations are running, allowing you to profile CPU, GPU, and memory utilization per node. This can help in understanding resource usage and optimizing performance.

## Prerequisites

Ensure you have the following installed on your system:

- `nvidia-smi`
- `mpstat`
- `free`
- `mpirun`

## Script Overview

- `get_gpu_utilization`: Collects GPU utilization data.
- `get_cpu_utilization`: Collects CPU utilization data.
- `generate_cpu_header`: Generates the CPU header for the CSV file.
- `generate_gpu_header`: Generates the GPU header for the CSV file.
- `get_memory_usage`: Collects memory usage data.
- `calculate_averages`: Calculates averages for comma-separated values.

## Usage

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/system-info-collector.git
    cd system-info-collector
    ```

2. Make the script executable:
    ```bash
    chmod +x collect_system_info.sh
    ```

3. Run the script:
    ```bash
    ./collect_system_info.sh
    ```

### Running with mpirun

To run the script using `mpirun`, ensure you have OpenMPI installed. The following command runs the script across multiple processes:

```bash
mpirun -np <number_of_processes> ./collect_system_info.sh

