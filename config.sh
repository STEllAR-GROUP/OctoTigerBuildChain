: ${POWERTIGER_ROOT:?} ${BUILD_TYPE:?}

export INSTALL_ROOT=${POWERTIGER_ROOT}/build
export SOURCE_ROOT=${POWERTIGER_ROOT}/src

################################################################################
# Package Configuration
################################################################################
# CMake
export CMAKE_VERSION=3.13.2

# GCC
if [[ "$2" == "without-cuda" ]]; then
    export GCC_VERSION=8.3.0
else
    echo "Using older gcc 7.4 for nvcc compatibility"
    export GCC_VERSION=7.4.0
fi
    

export OPENMPI_VERSION=4.0.0

# HDF5
export HDF5_VERSION=1.8.12

# Boost
export BOOST_VERSION=1.68.0
export BOOST_ROOT=${INSTALL_ROOT}/boost
export BOOST_BUILD_TYPE=$(echo ${BUILD_TYPE/%WithDebInfo/ease} | tr '[:upper:]' '[:lower:]')

# jemalloc
export JEMALLOC_VERSION=5.1.0

# hwloc
export HWLOC_VERSION=1.11.12

# Silo
export SILO_VERSION=4.10.2

# Vc
export VC_VERSION=1.4.1

# HPX
# Octotiger does not currently work with current master/HEAD
export HPX_VERSION=65c22662ccd5c63f43421cf76ca29d8222bf7f23

# PAPI
export PAPI_VERSION=5.5.1

# CUDA
export CUDA_SM=sm_61

#Libfabric
export LIBFABRIC_VERSION=1.9.0

# Max number of parallel jobs
export PARALLEL_BUILD=$(grep -c ^processor /proc/cpuinfo)

################################################################################
# Host-specific configuration
################################################################################
case $(hostname) in
    krypton)
        echo 'Compiling for krypton, doing additional setup'
        module load cuda-9.2
        ;;
    rostam*|geev|bahram|reno|tycho|trillian*|marvin*)
        echo 'Compiling for rostam, doing additional setup'
        module load cuda/9.2.14
        ;;
    *argon-tesla1*)
        echo 'Compiling for argon-tesla1, doing additional setup'
        export GCC_VERSION=6.5.0
        source /usr/local.nfs/Modules/4.3.0/init/bash
        module load cuda-9.0
        export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
        export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64"
        export CUDA_VISIBLE_DEVICES=0,1
        #export LD_LIBRARY_PATH=/usr/local.nfs/sw/cuda/cuda-9.0/lib64:$LD_LIBRARY_PATH
        ;;
    *argon-tesla2*)
        export GCC_VERSION=6.5.0
        echo 'Compiling for argon-tesla2, doing additional setup'
        source /usr/local.nfs/Modules/4.3.0/init/bash
        module load cuda-9.0
        export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
        export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
        export CUDA_VISIBLE_DEVICES=0,1
        ;;
    *)
        echo 'Compiling for a generic machine, expecting CUDA in "/usr/local/cuda"'
        export CUDAFLAGS=""
        ;;
esac

