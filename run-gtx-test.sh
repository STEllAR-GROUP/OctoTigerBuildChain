#!/bin/bash
# Author: Gregor Daiss
# Do whatever you want with this!

# Get base dir
basedir=$(pwd)
# Get current date
today=$(date +%m-%d-%H-%M)
cd octotiger
current_commit_message=$(git log --oneline -n 1)
cd "$basedir"
result_folder="${current_commit_message}-$today"
result_folder="$(echo "$result_folder" | sed -e 's/[ \t]/-/g')"
mkdir "$result_folder"
cd "$result_folder"

# Get scenario arguments and current commits
octotiger_args="-t 4 --problem=moving_star --max_level=2 --odt=0.3 --theta=0.35 --stop_time=0.2 \
--xscale=12 --omega=0.1 --stop_step=9 --disable_output=false --p2p_kernel_type=SOA_CPU \
--p2m_kernel_type=SOA_CPU --multipole_kernel_type=SOA_CPU"
echo "$octotiger_args" > LOG.txt

result_filename="results.txt"
echo ";number_of_cuda_streams total_runtime, computation_runtime,cpu launches multipole, cuda \
launches multipole, percentage of multipole launches on GPU, cpu launches p2p, cpu launches\
p2p, percentage of multipole" > "$result_filename"
for i in $(seq 0 1 8); do
    echo "---->>Running test $i" | tee -a LOG.txt
    output=$(nvprof "../octotiger/build/octotiger" $octotiger_args --cuda_streams_per_locality=$i --cuda_streams_per_gpu=32)
    filename="scenario${i}_output.txt"
    echo "$output" > "$filename"

    total_time=$(echo "$output" | grep Total: | sed 's/   Total: //g')
    computation_time=$(echo "$output" | grep Computation: | sed 's/   Computation: //g')
    cpu_multipole=$(echo "$output" | grep 'CPU multipole launches' | sed 's/CPU multipole launches //g')
    cuda_multipole=$(echo "$output" | grep 'CUDA multipole launches' | sed 's/CUDA multipole launches //g')
    multipole_percentage=$(echo "$output" | grep '=> Percentage of multipole on the GPU: ' | sed 's/=> Percentage of multipole on the GPU: //g')
    cpu_p2p=$(echo "$output" | grep 'CPU p2p launches' | sed 's/CPU p2p launches //g')
    cuda_p2p=$(echo "$output" | grep 'CUDA p2p launches' | sed 's/CUDA p2p launches //g')
    p2p_percentage=$(echo "$output" | grep '=> Percentage of multipole on the GPU: ' | sed 's/=> Percentage of multipole on the GPU: //g')

    echo "$i, $total_time , $computation_time , $cpu_multipole , $cuda_multipole , \
$multipole_percentage , $cpu_p2p , $cuda_p2p , $p2p_percentage"
    echo "$i, $total_time , $computation_time , $cpu_multipole , $cuda_multipole , \
$multipole_percentage , $cpu_p2p , $cuda_p2p , $p2p_percentage" >> "$result_filename"
done
profiling=$(perf record "../octotiger/build/octotiger" $octotiger_args --cuda_streams_per_locality=0 --cuda_streams_per_gpu=0)
echo "$profiling" > "scenario_profiling.txt"
