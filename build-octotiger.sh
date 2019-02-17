#!/usr/bin/env bash

set -ex

DIR_SRC=${SOURCE_ROOT}/octotiger
DIR_BUILD=${INSTALL_ROOT}/octotiger/build
#DIR_INSTALL=${INSTALL_ROOT}/octotiger

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git ${DIR_SRC}
fi

export LD_LIBRARY_PATH=$INSTALL_ROOT/gcc/lib64:$INSTALL_ROOT/silo/lib/:$INSTALL_ROOT/hdf5/lib:$LD_LIBRARY_PATH
export HDF5_ROOT=$INSTALL_ROOT/hdf5/

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_PREFIX_PATH=${POWERTIGER_ROOT}/build/hpx \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS -lz -L$INSTALL_ROOT/hdf5/lib -lhdf5" \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
    -DBOOST_ROOT=$INSTALL_ROOT/boost \
    -DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DVc_DIR=$INSTALL_ROOT/Vc/lib/cmake/Vc \
    -DOCTOTIGER_WITH_SILO=ON \
    -DBOOST_ROOT=$BOOST_ROOT \
    -DHPX_DIR=$INSTALL_ROOT/hpx/$LIBHPX/cmake/HPX/  \
    -DHDF5_INCLUDE_DIR=$INSTALL_ROOT/hdf5/include \
    -DHDF5_LIBRARY=$INSTALL_ROOT/hdf5/lib/libhdf5.a \
    -DSilo_DIR=$INSTALL_ROOT/silo \
    -DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -ccbin $INSTALL_ROOT/gcc/bin -std=c++14" \
    -DOCTOTIGER_WITH_BLAST_TEST=OFF

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1

