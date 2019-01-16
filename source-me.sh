#!/bin/bash


export USED_GCC_VERSION=6.5.0
export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))
export octotiger_source_me_sources=1
