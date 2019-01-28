#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    . source-me.sh
    . source-gcc.sh
fi


cd $SOURCE_ROOT
if [ ! -d octotiger ] ; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git
    cd octotiger
    git checkout master
    cd ..
fi

cd $INSTALL_ROOT
mkdir -p octotiger
cd octotiger

export LD_LIBRARY_PATH=$INSTALL_ROOT/gcc/lib64:$INSTALL_ROOT/silo/lib/:$INSTALL_ROOT/hdf5/lib:$LD_LIBRARY_PATH
export HDF5_ROOT=$INSTALL_ROOT/hdf5/

$INSTALL_ROOT/cmake/bin/cmake \
-DCMAKE_PREFIX_PATH=${BUILD_ROOT}/build/hpx \
-DCMAKE_CXX_COMPILER=$CXX \
-DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive" \
-DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS -lz -L$INSTALL_ROOT/hdf5/lib -lhdf5" \
-DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
-DBOOST_ROOT=$INSTALL_ROOT/boost/$BOOST_VER \
-DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
-DCMAKE_BUILD_TYPE=$BUILDTYPE \
-DVc_DIR=$INSTALL_ROOT/Vc/lib/cmake/Vc \
-DOCTOTIGER_WITH_SILO=ON \
-DBOOST_ROOT=$BOOST_ROOT \
-DHPX_DIR=$INSTALL_ROOT/hpx/$LIBHPX/cmake/HPX/  \
-DHDF5_INCLUDE_DIR=$INSTALL_ROOT/hdf5/include \
-DHDF5_LIBRARY=$INSTALL_ROOT/hdf5/lib/libhdf5.a \
-DSilo_INCLUDE_DIR=$INSTALL_ROOT/silo/include \
-DSilo_LIBRARY=$INSTALL_ROOT/silo/lib/libsiloh5.a \
-DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -ccbin $INSTALL_ROOT/gcc/bin -std=c++14" \
-DOCTOTIGER_WITH_BLAST_TEST=OFF \
$SOURCE_ROOT/octotiger

make -j${PARALLEL_BUILD}  VERBOSE=1
