#!/bin/bash
source env.sh
db_name=${1:-vidb}
test_name=${2:-test}
echo "db_name: $db_name, test_name=$test_name"

# define experiment parameters
operationCounts=("1M" "10M") # Human-readable operation counts
rangeSizes=("5" "50" "100" "200" "300" "400" "500" "1000" "2000")
valueSize=1024
batchSizes=(10000)

# directory
dataPath="${datadir}"
outputDir="${resdir}/results_${db_name}/range_benchmark_${test_name}"
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
        for rs in "${rangeSizes[@]}"; do
            rangeLog="${outputDir}/range-query_${human_op}_${rs}_${timestamp}.log"
            rangeCmd="${builddir}/build_release_${db_name}/vidb range_query --batchSize=$batchSize --dataPath=$dataPath --operationCount=$operationCount --rs=$rs --valueSize=$valueSize"
            run_benchmark "$rangeCmd" "$rangeLog" "range query benchmark (ops=${human_op}, batch=${batchSize})"
        done
    done
done

# Calculate and display total execution time
total_end_time=$(date +%s)
total_execution_time=$((total_end_time - total_start_time))
echo "All benchmarks completed successfully in $total_execution_time seconds. Results saved in $outputDir/"
