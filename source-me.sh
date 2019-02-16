export BUILD_ROOT=$(pwd)
export INSTALL_ROOT=$BUILD_ROOT/build
export SOURCE_ROOT=$BUILD_ROOT/src
mkdir -p ${BUILD_ROOT}/{src,build}

################################################################################
# Boost
export BOOST_VERSION=1.68.0
export BOOST_ROOT=$INSTALL_ROOT/boost

# GCC
export USED_GCC_VERSION=6.5.0

# CUDA
export CUDA_SM=sm_61

# Max number of parallel jobs
export PARALLEL_BUILD=$(grep -c ^processor /proc/cpuinfo)

export octotiger_source_me_sources=1

################################################################################
# Host-specific configuration
################################################################################
hostid=$(hostname)
if [[ ${hostid} == krypton ]]; then
    echo "compiling for krypton, doing additional setup";
    module load cuda-9.2
elif echo $hostid | grep -Fxq argon-tesla1; then
    echo "compiling for argon-tesla1, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-9.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64"
    export CUDA_VISIBLE_DEVICES=0,1
    export LD_LIBRARY_PATH=/usr/local.nfs/sw/cuda/cuda-9.0/lib64:$LD_LIBRARY_PATH
elif echo $hostid | grep -Fxq argon-tesla2; then
    echo "compiling for argon-tesla2, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-9.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME \
 -L$CUDATOOLKIT_HOME/lib64 \
 -L$CUDATOOLKIT_HOME/extras/CUPTI/lib64 \
 -lcudart_static -ldl -lrt -pthread \
 -lcuda -lcublas "
    export CUDA_VISIBLE_DEVICES=0,1
else
    echo "compiling for normal desktop machine, expecting cuda in /usr/local/cuda";
    export CUDAFLAGS=""
fi


################################################################################
# Command-line help
################################################################################
function print_synopsis
{
    cat <<EOF
SYNOPSIS
    ${0} [Release|RelWithDebInfo|Debug] [with-cuda|without-cuda]
DESCRIPTION
    Download, configure, build, and install Octo-tiger and its dependencies
EOF
    exit 1
}

################################################################################
# Command-line options
################################################################################
if [[ "$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug" ]]; then
    export BUILDTYPE=$1
    echo "Build Type: ${BUILDTYPE}"
else
    print_synopsis
fi

if [[ "$2" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
    echo "CUDA Support: Enabled"
elif [[ "$2" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
    echo "CUDA Support: Disabled"
else
    print_synopsis
fi
