#!/bin/bash


export USED_GCC_VERSION=6.5.0
export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))
export CUDA_SM=sm_61
export BUILDTYPE=Release
export octotiger_source_me_sources=1
