: ${POWERTIGER_ROOT:?} ${BUILD_TYPE:?}

export INSTALL_ROOT=${POWERTIGER_ROOT}/build
export SOURCE_ROOT=${POWERTIGER_ROOT}/src

################################################################################
# Package Configuration
################################################################################
# CMake
export CMAKE_VERSION=3.19.5

# GCC
export GCC_VERSION=10.3.0

export CLANG_VERSION=release/12.x
    

export OPENMPI_VERSION=4.0.0

# HDF5
export HDF5_VERSION=1.8.12

# Boost
export BOOST_VERSION=1.75.0
export BOOST_ROOT=${INSTALL_ROOT}/boost
export BOOST_BUILD_TYPE=$(echo ${BUILD_TYPE/%WithDebInfo/ease} | tr '[:upper:]' '[:lower:]')

# jemalloc
export JEMALLOC_VERSION=5.2.1

# hwloc
export HWLOC_VERSION=1.11.12

# Silo
export SILO_VERSION=4.10.2

# Vc
export VC_VERSION=1.4.1

# HPX
# Octotiger does not currently work with current master/HEAD
#export HPX_VERSION=65c22662ccd5c63f43421cf76ca29d8222bf7f23
# It does in reconstruct_experimental

export HPX_VERSION=1.8.0
export KOKKOS_VERSION=develop
export HPX_KOKKOS_VERSION=master

#export HPX_VERSION=1.7.1
#export KOKKOS_VERSION=d1e00352fd6262fd8d08225eb7086793432db35f
#export HPX_KOKKOS_VERSION=0.2.0

# PAPI
export PAPI_VERSION=5.7.0

export OTF2_VERSION=2.2

# CUDA
#export CUDA_SM=sm_86
export CUDA_SM=sm_80
#export CUDA_SM=sm_61
#export KOKKOS_CONFIG=" -DKokkos_ARCH_POWER9=ON -DKokkos_ARCH_VOLTA70=ON "
#export KOKKOS_CONFIG=" -DKokkos_ARCH_HSW=ON  -DKokkos_ARCH_VOLTA70=ON "
#export KOKKOS_CONFIG=" -DKokkos_ARCH_HSW=ON  -DKokkos_ARCH_PASCAL61=ON "
#export KOKKOS_CONFIG=" -DKokkos_ARCH_HSW=ON  -DKokkos_ARCH_AMPERE86=ON "
#export KOKKOS_CONFIG=" -DKokkos_ARCH_SKX=ON  -DKokkos_ARCH_MAXWELL50=ON "
export KOKKOS_CONFIG=" -DKokkos_ARCH_HSW=ON  -DKokkos_ARCH_VEGA908=ON "


#Libfabric
export LIBFABRIC_VERSION=1.9.0

# Max number of parallel jobs
export PARALLEL_BUILD=8  #$(grep -c ^processor /proc/cpuinfo)

export LIB_DIR_NAME=lib

################################################################################
# Host-specific configuration
################################################################################
case $(hostname) in
    pcsgs)
        echo 'Compiling for pcsgs, doing additional setup'
        export GCC_VERSION=7.4.0
        export PARALLEL_BUILD=8
        ;;
    krypton)
        echo 'Compiling for krypton, doing additional setup'
        module load cuda/10.2
        export LIB_DIR_NAME=lib64
        export PARALLEL_BUILD=16
        ;;
    diablo*)
        echo 'Compiling for diablo, doing additional setup'
        export LIB_DIR_NAME=lib64
        export CUDA_SM=sm_70
        export KOKKOS_CONFIG=" -DKokkos_ARCH_SKX=ON  -DKokkos_ARCH_VOLTA70=ON "
        export PARALLEL_BUILD=16
        ;;
    workbook)
        echo 'Compiling for diablo, doing additional setup'
        export CUDA_SM=sm_75
        export KOKKOS_CONFIG=" -DKokkos_ARCH_SKX=ON  -DKokkos_ARCH_TURING75=ON "
        ;;
    geev*)
        echo 'Compiling for geev, doing additional setup'
        export LIB_DIR_NAME=lib64
        export CUDA_SM=sm_70
        export KOKKOS_CONFIG=" -DKokkos_ARCH_HSW=ON  -DKokkos_ARCH_VOLTA70=ON "
        export PARALLEL_BUILD=16
        ;;
    medusa*)
        echo 'Compiling for medusa, doing additional setup'
        export LIB_DIR_NAME=lib64
        export KOKKOS_CONFIG=" -DKokkos_ARCH_SKX=ON "
        export PARALLEL_BUILD=20
        ;;
    toranj*)
        echo 'Compiling for toranj, doing additional setup'
        export LIB_DIR_NAME=lib64
        export CUDA_SM=sm_80
        export KOKKOS_CONFIG=" -DKokkos_ARCH_SKX=ON  -DKokkos_ARCH_AMPERE80=ON "
        export PARALLEL_BUILD=20
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

