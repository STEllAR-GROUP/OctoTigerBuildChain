#!/bin/bash
max_cpu_threads=8
max_gpu_executors=32
max_level=4
stop_step=10

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
octotiger_args="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --restart_file=../final.silo --disable_diagnostics=on --disable_output=off --stop_step=${stop_step} --theta=0.34 "
eval "./build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args"
cd "$result_folder"
cp ../final.silo final.silo
cp -r ../final.silo.data final.silo.data

# 0. Testing with Vc kernels (baseline
# ---------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos without-simd without-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
octotiger_args="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --restart_file=../final.silo --disable_diagnostics=on --disable_output=on --stop_step=${stop_step} --theta=0.34 "
gpu_args=" --cuda_streams_per_gpu=0 --cuda_buffer_capacity=1 "
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
# Running tests
echo "# Date of run $today" > test0_cpuonly_vc_results.txt
echo "# Measuring computation time using only vc host kokkos kernels" >> test0_cpuonly_vc_results.txt
echo "# threads, runtime" >> test0_cpuonly_vc_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}"
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test0_cpuonly_vc_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 1. Testing without simd (serial backend)
# ---------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos without-simd without-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
gpu_args=" --cuda_streams_per_gpu=0 --cuda_buffer_capacity=1 "
kernel_args=" --multipole_device_kernel_type=KOKKOS_CUDA --monopole_device_kernel_type=KOKKOS_CUDA --multipole_host_kernel_type=KOKKOS --monopole_host_kernel_type=KOKKOS "
# Running tests
echo "# Date of run $today" > test1_cpuonly_scalar_results.txt
echo "# Measuring computation time using only scalar host kokkos kernels" >> test1_cpuonly_scalar_results.txt
echo "# threads, runtime" >> test1_cpuonly_scalar_results.txt
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test1_cpuonly_scalar_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 2. Testing with simd (serial backend)
# ---------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd without-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
# Running tests
echo "# Date of run $today" > test2_simd_cpuonly_results.txt
echo "# Measuring computation time using only host kokkos kernels (with simd)" >> test2_simd_cpuonly_results.txt
echo "# threads, runtime" >> test2_simd_cpuonly_results.txt
pushd ..
echo "building configuration..."
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test2_simd_cpuonly_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 3. Testing with multipoles using the hpx backend
# ------------------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd with-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
# Running tests
echo "# Date of run $today" > test3_multipolehpx_results.txt
echo "# Date of run $today" > test3_multipolehpx_log.txt
echo "# Measuring computation time using multipole kernels with hpx backend" >> test3_multipolehpx_results.txt
echo "# threads, runtime" >> test3_multipolehpx_results.txt
pushd ..
echo "building configuration..."
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test3_multipolehpx_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 4. Testing with all kernels using the hpx backend
# ------------------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd with-hpx-backend-multipole with-hpx-backend-monopole without-hpx-cuda-polling octotiger"
# Running tests
echo "# Date of run $today" > test4_allhpx_results.txt
echo "# Measuring computation time using all kernels with hpx backend" >> test4_allhpx_results.txt
echo "# threads, runtime" >> test4_allhpx_results.txt
pushd ..
echo "building configuration..."
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"

	echo "$compute_time" >> "test4_allhpx_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# ===============================================
# ===============================================
# GPU Testing
gpu_args=" --cuda_streams_per_gpu=32 --cuda_buffer_capacity=1 "
octotiger_args="--problem=solid_sphere --max_level=${max_level} --hydro=off --xscale=1.0 --restart_file=../final.silo --disable_diagnostics=on --disable_output=on --stop_step=${stop_step} --theta=0.34 "

# 5. Testing for Vc + CUDA Baseline
# ------------------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd with-hpx-backend-multipole with-hpx-backend-monopole without-hpx-cuda-polling octotiger"
kernel_args=" --multipole_device_kernel_type=CUDA --monopole_device_kernel_type=CUDA --multipole_host_kernel_type=Vc --monopole_host_kernel_type=Vc "
echo "# Date of run $today" > test5_gpu_baseline_results.txt
echo "# Measuring computation time using Vc + CUDA kernels (GPU args: $gpu_args " >> test5_gpu_baseline_results.txt
echo "# threads, runtime" >> test5_gpu_baseline_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"

	echo "$compute_time" >> "test5_gpu_baseline_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 6. Same build but with KOKKOS GPU (+ CPU) Kernels
# -------------------------------------------------
kernel_args=" --multipole_device_kernel_type=KOKKOS_CUDA --monopole_device_kernel_type=KOKKOS_CUDA --multipole_host_kernel_type=KOKKOS --monopole_host_kernel_type=KOKKOS "
echo "# Date of run $today" > test6_kokkos_gpu_results.txt
echo "# Measuring computation time using Kokkos CPU+GPU kernels (GPU args: $gpu_args " >> test6_kokkos_gpu_results.txt
echo "# threads, runtime" >> test6_kokkos_gpu_results.txt
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test6_kokkos_gpu_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 7. Same build but with KOKKOS GPU (+ CPU) Kernels and HPX backend for multipoles
# --------------------------------------------------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd with-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
echo "# Date of run $today" > test7_kokkos_gpu_multipole_hpx_backend_results.txt
echo "# Measuring computation time using Kokkos CPU+GPU kernels and the multipole HPX backend (GPU args: $gpu_args " >> test7_kokkos_gpu_multipole_hpx_backend_results.txt
echo "# threads, runtime" >> test7_kokkos_gpu_multipole_hpx_backend_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test7_kokkos_gpu_multipole_hpx_backend_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 8. Same build but with KOKKOS GPU (+ CPU) Kernels and HPX backend for all kernels
# --------------------------------------------------------------------------------
build_command="./build-all.sh Release with-gcc with-cuda without-mpi without-papi without-apex with-kokkos with-simd with-hpx-backend-multipole without-hpx-backend-monopole without-hpx-cuda-polling octotiger"
echo "# Date of run $today" > test8_kokkos_gpu_allkernel_hpx_backend_results.txt
echo "# Measuring computation time using Kokkos CPU+GPU kernels and the allkernel HPX backend (GPU args: $gpu_args " >> test8_kokkos_gpu_allkernel_hpx_backend_results.txt
echo "# threads, runtime" >> test8_kokkos_gpu_allkernel_hpx_backend_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 ${max_cpu_threads}`; do
  output1="$(./../build/octotiger/build/octotiger -t$i $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test8_kokkos_gpu_allkernel_hpx_backend_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 9. Testing increasing numbers of executors
#-------------------------------------------
echo "# Date of run $today" > test9_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors " >> test9_kokkos_gpu_executor_results.txt
echo "# executors, runtime" >> test9_kokkos_gpu_executor_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 32`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=1 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "test9_kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

# 10. Testing increasing numbers of executors with larger queues
#--------------------------------------------------------------
echo "# Date of run $today" > test10_kokkos_gpu_executor_results.txt
echo "# Measuring computation time using a varying number of device executors (queue length 4) " >> test10_kokkos_gpu_executor_results.txt
echo "# threads, runtime" >> test10_kokkos_gpu_executor_results.txt
pushd ..
rm -rf "./build/octotiger/build"
eval "${build_command}" 
popd
for i in `seq 1 1 32`; do
  gpu_args=" --cuda_streams_per_gpu=${i} --cuda_buffer_capacity=4 "
  output1="$(./../build/octotiger/build/octotiger -t${max_cpu_threads} $octotiger_args $gpu_args $kernel_args | tee -a LOG.txt )"
  compute_time="$i, $(echo "$output1" | grep '==> Average iteration execution time:' | sed 's/==> Average iteration execution time://g' | sed 's/ms//g')"
	echo "$compute_time" >> "kokkos_gpu_executor_results.txt"
	echo "$compute_time" | tee -a LOG.txt
done

echo "All done!" | tee -a LOG.txt
