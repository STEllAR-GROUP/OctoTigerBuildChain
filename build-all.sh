#!/bin/bash
set -e
set -x

source source-me.sh
echo "Building gcc"
./build-gcc.sh
source source-gcc.sh
echo "Building boost"
./build-boost.sh
echo "Building cmake"
./build-cmake.sh
echo "Building hdf5"
./build-hdf5.sh
echo "Building silo"
./build-silo.sh
echo "Building hwloc"
./build-hwloc.sh
echo "Building jemalloc"
./build-jemalloc.sh
echo "Building vc"
./build-Vc.sh
echo "Building hpx"
./build-hpx.sh
echo "Building octotiger"
./build-octotiger.sh
