#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
fi

    . source-gcc.sh

if [ ! -d octotiger ] ; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git
    cd octotiger
    git checkout flopcounter
    cd ..
fi

cd octotiger
mkdir -p build
cd build/
#rm CMakeCache.txt
echo $(pwd)

export LD_LIBRARY_PATH=$HOME/opt/gcc/lib64:$HOME/opt/silo/lib/:$HOME/opt/hdf5/lib:$LD_LIBRARY_PATH
export HDF5_ROOT=$HOME/opt/hdf5/

$HOME/opt/cmake/bin/cmake \
-DCMAKE_PREFIX_PATH=${BUILD_ROOT}/build/hpx \
-DCMAKE_CXX_COMPILER=$CXX \
-DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive" \
-DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS $CUDAFLAGS -lz -L$HOME/opt/hdf5/lib -lhdf5" \
-DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS $CUDAFLAGS" \
-DBOOST_ROOT=$INSTALL_ROOT/boost/$BOOST_VER \
-DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
-DCMAKE_BUILD_TYPE=$BUILDTYPE \
-DVc_DIR=$HOME/opt/Vc/lib/cmake/Vc \
-DOCTOTIGER_WITH_SILO=ON \
-DBOOST_ROOT=$HOME/opt/boost/ \
-DHPX_DIR=$HOME/opt/hpx/$LIBHPX/cmake/HPX/  \
-DHDF5_INCLUDE_DIR=$HOME/opt/hdf5/include \
-DHDF5_LIBRARY=$HOME/opt/hdf5/lib/libhdf5.a \
-DSilo_INCLUDE_DIR=$HOME/opt/silo/include \
-DSilo_LIBRARY=$HOME/opt/silo/lib/libsiloh5.a \
-DCMAKE_CUDA_FLAGS="-ccbin $HOME/opt/gcc/bin -std=c++14" \
../

make -j${PARALLEL_BUILD}  VERBOSE=1
