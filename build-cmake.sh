#!/bin/bash
set -x
set -e

if [ -z ${octotiger_source_me_sources} ] ; then
	. source-me.sh
fi


if [ ! -d "cmake-3.13.2/" ]; then
   wget https://github.com/Kitware/CMake/releases/download/v3.13.2/cmake-3.13.2.tar.gz
   tar -xf cmake-3.13.2.tar.gz 
fi
cd cmake-3.13.2
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$HOME/opt/cmake ..
make -j${PARALLEL_BUILD}
make install



