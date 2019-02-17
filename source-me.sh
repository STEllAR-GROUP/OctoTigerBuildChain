export BUILD_ROOT=$(pwd)
export INSTALL_ROOT=$BUILD_ROOT/build
export SOURCE_ROOT=$BUILD_ROOT/src
mkdir -p ${BUILD_ROOT}/{src,build}

################################################################################
# CMake
export CMAKE_VERSION=3.13.2

# GCC
export GCC_VERSION=6.5.0

# HDF5
export HDF5_VERSION=1.10.4

# Boost
export BOOST_VERSION=1.68.0
export BOOST_ROOT=$INSTALL_ROOT/boost

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
        echo 'Compiling for krypton, doing additional setup';
        module load cuda-9.2
        ;;
    *argon-tesla1*)
        echo 'Compiling for argon-tesla1, doing additional setup';
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
        echo 'Compiling for argon-tesla2, doing additional setup';
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
        echo 'Compiling for a generic machine, expecting CUDA in "/usr/local/cuda"';
        export CUDAFLAGS=""
        ;;
esac

################################################################################
# Command-line help
################################################################################
print_synopsis ()
{
    cat <<EOF >&2
SYNOPSIS
    ${0} {Release|RelWithDebInfo|Debug} {with-cuda|without-cuda}
DESCRIPTION
    Download, configure, build, and install Octo-tiger and its dependencies
EOF
    exit 1
}

################################################################################
# Command-line options
################################################################################
if [[ "$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug" ]]; then
    export BUILD_TYPE=$1
    echo "Build Type: ${BUILD_TYPE}"
else
    echo 'Build type must be provided and has to be "Release", "RelWithDebInfo", or "Debug"' >&2
    print_synopsis
fi

if [[ "$2" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "CUDA Support: Enabled"
elif [[ "$2" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
    echo "CUDA Support: Disabled"
else
    echo 'CUDA support must be specified and has to be "with-cuda"  or "without-cuda"' >&2
    print_synopsis
fi

