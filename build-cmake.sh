#!/bin/bash
set -x
set -e

CMAKE_VERSION=3.13.2
if [ -z ${octotiger_source_me_sources} ]; then
	. source-me.sh
fi

if [ ! -d "cmake-${CMAKE_VERSION}/" ]; then
   curl -JL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz | tar xz
fi
cd cmake-${CMAKE_VERSION}
mkdir build
cd build
./bootstrap --parallel=${PARALLEL_BUILD} --prefix=$HOME/opt/cmake
make install



