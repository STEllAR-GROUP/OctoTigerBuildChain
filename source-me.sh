#!/bin/bash

echo $@
export USED_GCC_VERSION=6.5.0
export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))
export CUDA_SM=sm_61
#export BUILDTYPE=Release
export octotiger_source_me_sources=1

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
