#!/bin/bash
max_cpu_threads=10
max_gpu_executors=128
max_level=4
stop_step=20

# Get base dir
basedir=`pwd`
# Get current date
today=`date +%Y-%m-%d_%H:%M:%S`
# Create Test folder
result_folder="Testrun-$today"
mkdir "$result_folder"


# Log configuration
echo "Using scenarion file: $1" | tee "$result_folder/LOG.txt"

# Create input files files
octotiger_args_gen="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --disable_diagnostics=on --disable_output=off --stop_step=1 --theta=0.34 "
eval "./build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args_gen"
cd "$result_folder"
cp ../final.silo final.silo
cp -r ../final.silo.data final.silo.data

# ===============================================
# ===============================================
# GPU Testing with events
gpu_args=" --cuda_streams_per_gpu=${max_gpu_executors} --cuda_buffer_capacity=1 "
octotiger_args="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --restart_file=../final.silo --disable_diagnostics=on --disable_output=on --stop_step=${stop_step} --theta=0.34 "

# 5. Testing for Vc + CUDA Baseline
# ------------------------------------------------
build_command="./build-all.sh Release with-CC with-cuda without-mpi without-papi without-apex with-kokkos with-simd without-hpx-backend-multipole without-hpx-backend-monopole with-hpx-cuda-polling kokkos octotiger"
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
echo "# Date of run $today" > test1_gpu_baseline_results.txt
echo "# Measuring computation time using Vc + CUDA kernels (GPU args: $gpu_args " >> test1_gpu_baseline_results.txt
echo "# threads, runtime" >> test1_gpu_baseline_results.txt
pushd ..
rm -rf "./build/octotiger/build"
rm -rf "./build/kokkos"
rm -rf "./build/hpx-kokkos"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"

	echo "$compute_time" >> "test1_gpu_baseline_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 55 Testing for Vc + CUDA Baseline
#-------------------------------------------
echo "# Date of run $today" > test2_cuda_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of CUDA +vc device executors / polling " >> test2_cuda_gpu_executor_results.txt
echo "# executors, runtime" >> test2_cuda_gpu_executor_results.txt
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=1 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test2_cuda_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 55 Testing for Vc + CUDA Baseline
#-------------------------------------------
echo "# Date of run $today" > test3_cuda_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of CUDA +vc device executors / polling / queue 2048 " >> test3_cuda_gpu_executor_results.txt
echo "# executors, runtime" >> test3_cuda_gpu_executor_results.txt
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=2048 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test3_cuda_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 6. Same build but with KOKKOS GPU (+ CPU) Kernels
# -------------------------------------------------
kernel_args=" --multipole_device_kernel_type=KOKKOS_CUDA --monopole_device_kernel_type=KOKKOS_CUDA --multipole_host_kernel_type=KOKKOS --monopole_host_kernel_type=KOKKOS "
echo "# Date of run $today" > test4_kokkos_gpu_results.txt
echo "# Measuring computation time using Kokkos CPU+GPU kernels (GPU args: $gpu_args " >> test4_kokkos_gpu_results.txt
echo "# threads, runtime" >> test4_kokkos_gpu_results.txt
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test4_kokkos_gpu_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 9. Testing increasing numbers of executors
#-------------------------------------------
echo "# Date of run $today" > test5_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors " >> test5_kokkos_gpu_executor_results.txt
echo "# executors, runtime" >> test5_kokkos_gpu_executor_results.txt
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=1 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test5_kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 10. Testing increasing numbers of executors with larger queues
#--------------------------------------------------------------
echo "# Date of run $today" > test6_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors (queue length 2048) " >> test6_kokkos_gpu_executor_results.txt
echo "# threads, runtime" >> test6_kokkos_gpu_executor_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=2048 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test6_kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done
# =========================================
# ===============================================
# GPU Testing with callbacks
gpu_args=" --cuda_streams_per_gpu=${max_gpu_executors} --cuda_buffer_capacity=1 "
octotiger_args="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --restart_file=../final.silo --disable_diagnostics=on --disable_output=on --stop_step=${stop_step} --theta=0.34 "

# 5. Testing for Vc + CUDA Baseline
# ------------------------------------------------
build_command="./build-all.sh Release with-CC with-cuda without-mpi without-papi without-apex with-kokkos with-simd without-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling kokkos octotiger"
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
echo "# Date of run $today" > test_callback1_gpu_baseline_results.txt
echo "# Measuring computation time using Vc + CUDA kernels (GPU args: $gpu_args " >> test_callback1_gpu_baseline_results.txt
echo "# threads, runtime" >> test_callback1_gpu_baseline_results.txt
pushd ..
rm -rf "./build/octotiger/build"
rm -rf "./build/kokkos"
rm -rf "./build/hpx-kokkos"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"

	echo "$compute_time" >> "test_callback1_gpu_baseline_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 55 Testing for Vc + CUDA Baseline
#-------------------------------------------
echo "# Date of run $today" > test_callback2_cuda_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of CUDA +vc device executors / polling " >> test_callback2_cuda_gpu_executor_results.txt
echo "# executors, runtime" >> test_callback2_cuda_gpu_executor_results.txt
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=1 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test_callback2_cuda_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 55 Testing for Vc + CUDA Baseline
#-------------------------------------------
echo "# Date of run $today" > test_callback3_cuda_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of CUDA +vc device executors / polling / queue 2048 " >> test_callback3_cuda_gpu_executor_results.txt
echo "# executors, runtime" >> test_callback3_cuda_gpu_executor_results.txt
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=2048 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test_callback3_cuda_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 6. Same build but with KOKKOS GPU (+ CPU) Kernels
# -------------------------------------------------
kernel_args=" --multipole_device_kernel_type=KOKKOS_CUDA --monopole_device_kernel_type=KOKKOS_CUDA --multipole_host_kernel_type=KOKKOS --monopole_host_kernel_type=KOKKOS "
echo "# Date of run $today" > test_callback4_kokkos_gpu_results.txt
echo "# Measuring computation time using Kokkos CPU+GPU kernels (GPU args: $gpu_args " >> test_callback4_kokkos_gpu_results.txt
echo "# threads, runtime" >> test_callback4_kokkos_gpu_results.txt
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test_callback4_kokkos_gpu_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 9. Testing increasing numbers of executors
#-------------------------------------------
echo "# Date of run $today" > test_callback5_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors " >> test_callback5_kokkos_gpu_executor_results.txt
echo "# executors, runtime" >> test_callback5_kokkos_gpu_executor_results.txt
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=1 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test_callback5_kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 10. Testing increasing numbers of executors with larger queues
#--------------------------------------------------------------
echo "# Date of run $today" > test_callback6_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors (queue length 2048) " >> test_callback6_kokkos_gpu_executor_results.txt
echo "# threads, runtime" >> test_callback6_kokkos_gpu_executor_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 0 2 128`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=2048 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test_callback6_kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

#
# 11. Teecho "All done!" | tee -a LOG.txt
