#!/usr/bin/env bash

set -e
set -x

source source-me.sh

# Build tools
echo "Building GCC"
./build-gcc.sh
echo "Building CMake"
./build-cmake.sh
export CMAKE_COMMAND=${INSTALL_ROOT}/cmake/bin/cmake

# Dependencies
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

# Octo-tiger
echo "Building Octo-tiger"
./build-octotiger.sh

