export BUILD_ROOT=$(pwd)
mkdir -p src
mkdir -p build
export INSTALL_ROOT=$BUILD_ROOT/build
export SOURCE_ROOT=$BUILD_ROOT/src
export BOOST_SUFFIX=1_68_0
export BOOST_VERSION=1.68.0
export BOOST_ROOT=$INSTALL_ROOT/boost/$BOOST_VER

export USED_GCC_VERSION=6.5.0
export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))
export CUDA_SM=sm_61
export octotiger_source_me_sources=1
hostid=$(hostname)

if [[ `echo $hostid | grep krypton` ]]; then
    echo "compiling for krypton, doing additional setup";
    module load cuda-9.2
elif [[ `echo $hostid | grep argon-tesla1` ]]; then
    echo "compiling for argon-tesla1, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-9.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-8.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME"
    export CUDA_VISIBLE_DEVICES=0,1
elif [[ `echo $hostid | grep argon-tesla2` ]]; then
    echo "compiling for argon-tesla2, doing additional setup";
    source /usr/local.nfs/Modules/init/bash
    module load cuda-9.0
    export CUDATOOLKIT_HOME=/usr/local.nfs/sw/cuda/cuda-9.0
    export CUDAFLAGS="--cuda-path=$CUDATOOLKIT_HOME"
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
