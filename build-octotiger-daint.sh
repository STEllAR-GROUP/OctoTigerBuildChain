#!/usr/bin/env bash

set -exo pipefail


SOURCE_ROOT=$PWD
INSTALL_ROOT=$PWD

DIR_SRC=${SOURCE_ROOT}/src/octotiger/
DIR_BUILD=${INSTALL_ROOT}/build/octotiger/build
#DIR_INSTALL=${INSTALL_ROOT}/octotiger

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git ${DIR_SRC} --branch=master
fi

CMAKE_version=3.12.0
MPI_version=7.7.2
CUDA_SM=sm_60

module unload PrgEnv-cray
module load   PrgEnv-gnu
module unload gcc
module load   gcc/7.3.0
module unload cray-libsci
module unload cray-mpich
module load   cray-mpich/$MPI_version
module load   daint-gpu
module load   CMake/$CMAKE_version
module load   cudatoolkit/9.2.148_3.19-6.0.7.1_2.1__g3d9acc8


CMAKE_COMMAND=$(which cmake)


export CC=/opt/cray/pe/craype/default/bin/cc
export CXX=/opt/cray/pe/craype/default/bin/CC

export CFLAGS=-fPIC
export CXXFLAGS="-fPIC -march=native -mtune=native -ffast-math -std=c++14"
export LDFLAGS="-dynamic"
export LDCXXFLAGS="$LDFLAGS -std=c++14 -latomic"

export LD_LIBRARY_PATH=/apps/daint/UES/biddisco/gcc/7.3.0/silo/lib/:/apps/daint/UES/biddisco/gcc/7.3.0/hdf5/1.10.4/lib/:$LD_LIBRARY_PATH

#    -DHDF5_INCLUDE_DIRS=/apps/daint/UES/biddisco/gcc/7.3.0/hdf5/1.10.4/include \
#    -DHDF5_LIBRARIES=/apps/daint/UES/biddisco/gcc/7.3.0/hdf5/1.10.4/lib/libhdf5.a \
${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_PREFIX_PATH=${INSTALL_ROOT}/hpx \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS -lz -L/apps/daint/UES/biddisco/gcc/7.3.0/hdf5/1.10.4/lib/ -lhdf5" \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS -lz" \
    -DOCTOTIGER_WITH_CUDA=ON \
    -DCUDA_HOST_COMPILER=/opt/gcc/6.2.0/bin/gcc \
    -DCMAKE_BUILD_TYPE=Release \
    -DVc_DIR=/apps/daint/UES/biddisco/gcc/7.3.0/Vc/lib/cmake/Vc \
    -DOCTOTIGER_WITH_SILO=ON \
    -DBOOST_ROOT=/apps/daint/UES/biddisco/gcc/7.3.0/boost/7.3.0/1.68.0/ \
    -DHPX_DIR=/apps/daint/UES/biddisco/gcc/7.3.0/hpx4octotiger-tcmalloc-release/lib64/cmake/HPX/ \
    -DHDF5_ROOT=/apps/daint/UES/biddisco/gcc/7.3.0/hdf5/1.10.4/ \
    -DSilo_DIR=/apps/daint/UES/biddisco/gcc/7.3.0/silo/ \
    -DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -std=c++14" \
    -DOCTOTIGER_WITH_BLAST_TEST=ON

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1

