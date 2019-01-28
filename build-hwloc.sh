#!/bin/bash
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi


cd $SOURCE_ROOT
if [ ! -f "hwloc-1.11.12.tar.gz" ]; then
   wget https://download.open-mpi.org/release/hwloc/v1.11/hwloc-1.11.12.tar.gz
   tar -xf hwloc-1.11.12.tar.gz 
fi
cd hwloc-1.11.12
./configure --prefix=$INSTALL_ROOT/hwloc/ --disable-opencl 
make -j ${PARALLEL_BUILD}
make install



