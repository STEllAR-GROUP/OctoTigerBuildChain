#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi




if [ ! -d "jemalloc-5.0.1/" ]; then
   wget https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2
   tar -xf jemalloc-5.1.0.tar.bz2
fi
cd jemalloc-5.1.0
./autogen.sh
./configure --prefix=$HOME/opt/jemalloc
make -j${PARALLEL_BUILD}
make install
