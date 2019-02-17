#!/usr/bin/env bash

set -e
set -x

source source-me.sh

export CMAKE=${INSTALL_ROOT}/cmake/bin/cmake

if [[ -z ${octotiger_source_me_sources} ]]; then
    source source-me.sh
    source source-gcc.sh
fi

echo "Building GCC"
./build-gcc.sh
echo "Building CMake"
./build-cmake.sh
source source-gcc.sh
echo "Building Boost"
./build-boost.sh
echo "Building HDF5"
./build-hdf5.sh
echo "Building Silo"
./build-silo.sh
echo "Building hwloc"
./build-hwloc.sh
echo "Building jemalloc"
./build-jemalloc.sh
echo "Building Vc"
./build-Vc.sh
echo "Building HPX"
./build-hpx.sh
echo "Building Octo-tiger"
./build-octotiger.sh
