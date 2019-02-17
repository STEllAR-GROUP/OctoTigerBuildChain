: ${POWERTIGER_ROOT:?'POWERTIGER_ROOT must be set to the appropriate path'}

export INSTALL_ROOT=${POWERTIGER_ROOT}/build
export SOURCE_ROOT=${POWERTIGER_ROOT}/src

################################################################################
# Package Configuration
################################################################################
# CMake
export CMAKE_VERSION=3.13.2

# GCC
export GCC_VERSION=6.5.0

# HDF5
export HDF5_VERSION=1.10.4

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

# CUDA
export CUDA_SM=sm_61

# Max number of parallel jobs
export PARALLEL_BUILD=$(grep -c ^processor /proc/cpuinfo)

export octotiger_source_me_sources=1

################################################################################
# Host-specific configuration
################################################################################
case $(hostname) in
    krypton)
        echo 'Compiling for krypton, doing additional setup'
        module load cuda-9.2
        ;;
    rostam)
        echo 'Compiling for rostam, doing additional setup'
        module load cuda/9.2.14
        ;;
    *argon-tesla1*)
        echo 'Compiling for argon-tesla1, doing additional setup'
        source /usr/local.nfs/Modules/init/bash
        module load cuda-9.0
        export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
        export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64"
        export CUDA_VISIBLE_DEVICES=0,1
        export LD_LIBRARY_PATH=/usr/local.nfs/sw/cuda/cuda-9.0/lib64:$LD_LIBRARY_PATH
        ;;
    *argon-tesla2*)
        echo 'Compiling for argon-tesla2, doing additional setup'
        source /usr/local.nfs/Modules/init/bash
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

