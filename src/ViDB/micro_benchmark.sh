#!/bin/bash
source env.sh
db_name=${1:-vidb}
test_name=${2:-test}
echo "db_name: $db_name, test_name=$test_name"

# define experiment parameters
operationCounts=("1M") # Human-readable operation counts
batchSizes=(500 1000 2000 3000 4000 5000)
valueSizes=(256 512 1024 2048)          
keySize=32

# directory
dataPath="${datadir}"
outputDir="${resdir}/results_${db_name}/micro_benchmark_${test_name}"
mkdir -p ${dataPath}
mkdir -p ${outputDir}
rm -rf ${dataPath}/*
rm -rf ${outputDir}/*

# unique testname
timestamp=${test_name}

# Start time for total execution
total_start_time=$(date +%s)

# Function to convert human-readable sizes to numbers
human_to_number() {
    local human_size=$1
    local num=${human_size%[KMG]}
    local unit=${human_size##*[0-9]}

    case $unit in
        K) echo $((num * 1000)) ;;
        M) echo $((num * 1000000)) ;;
        G) echo $((num * 1000000000)) ;;
        *) echo $num ;;  # No unit, assume it's already a number
    esac
}

# Function to run command with error checking and logging
run_benchmark() {
    local cmd=$1
    local logFile=$2
    local description=$3

    echo "=== Starting $description ===" | tee -a "$logFile"
    echo "Command: $cmd" | tee -a "$logFile"
    echo "Timestamp: $(date)" | tee -a "$logFile"

    # Run the command and capture output
    if $cmd >> "$logFile" 2>&1; then
        echo "=== Completed successfully ===" | tee -a "$logFile"
    else
        echo "=== FAILED with exit code $? ===" | tee -a "$logFile"
        exit 1
    fi

    echo -e "\n" | tee -a "$logFile"
}

# Main benchmark execution
for human_op in "${operationCounts[@]}"; do
    operationCount=$(human_to_number "$human_op")
    for batchSize in "${batchSizes[@]}"; do
        for valueSize in "${valueSizes[@]}"; do
            RandomPGtLog="${outputDir}/micro_${human_op}_${batchSize}_${valueSize}_${timestamp}.log"
            RandomPGtCmd="${builddir}/build_release_${db_name}/vidb randompgt --VlogSize=4 --dataPath=$dataPath --batchSize=$batchSize --operationCount=$operationCount --valueSize=$valueSize --keySize=$keySize"
            run_benchmark "$RandomPGtCmd" "$RandomPGtLog" "random-put-get benchmark (ops=${human_op}, batch=${batchSize})"
            sleep 5
        done 
    done
done

# Calculate and display total execution time
total_end_time=$(date +%s)
total_execution_time=$((total_end_time - total_start_time))
echo "All benchmarks completed successfully in $total_execution_time seconds. Results saved in ${outputDir}/"
