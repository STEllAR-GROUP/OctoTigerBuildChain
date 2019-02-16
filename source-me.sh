export BUILD_ROOT=$(pwd)
mkdir -p src
mkdir -p build
export INSTALL_ROOT=$BUILD_ROOT/build
export SOURCE_ROOT=$BUILD_ROOT/src
export BOOST_VERSION=1.68.0
export BOOST_ROOT=$INSTALL_ROOT/boost

export USED_GCC_VERSION=6.5.0
export PARALLEL_BUILD=$(grep -c ^processor /proc/cpuinfo)
export CUDA_SM=sm_61
export octotiger_source_me_sources=1
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


if [[ ! -z $1 ]]; then
    if [[ ! ("$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug") ]]; then
    echo "build type invalid: valid are Release, RelWithDebInfo and Debug"
    kill -INT $$
    fi
    export BUILDTYPE=$1
else
    echo "no build type specified: specify either Release, RelWithDebInfo or Debug as first argument"
    kill -INT $$
    # export BUILDTYPE=Release
fi
echo "build type: $BUILDTYPE"
if [[ ! -z $2 ]]; then
    if [[ ! ("$2" == "with-cuda" || "$2" == "without-cuda") ]]; then
    echo "no build cuda type specified: Use either with-cuda or without-cuda as second argument!"
    kill -INT $$
    fi
if [[ "$2" == "without-cuda" ]]; then
    export OCT_WITH_CUDA=OFF
elif [[ "$2" == "with-cuda" ]]; then
    export OCT_WITH_CUDA=ON
fi
else
    echo "no build cuda type specified: Use either with-cuda or without-cuda as second argument!"
    kill -INT $$
fi
