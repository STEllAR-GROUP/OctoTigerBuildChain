#!/bin/bash
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
fi

. source-gcc.sh


if [ ! -d "hwloc-1.11.12/" ]; then
   wget https://download.open-mpi.org/release/hwloc/v1.11/hwloc-1.11.12.tar.gz
   tar -xf hwloc-1.11.12.tar.gz 
fi
cd hwloc-1.11.12
./configure --prefix=$HOME/opt/hwloc/ --disable-opencl 
make -j 
make install



