#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${OCT_WITH_KOKKOS:?} \
    ${BOOST_ROOT:?} ${LIBHPX:?}

DIR_SRC=${SOURCE_ROOT}/octotiger
DIR_BUILD=${INSTALL_ROOT}/octotiger/build
#DIR_INSTALL=${INSTALL_ROOT}/octotiger

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git ${DIR_SRC}
    pushd ${DIR_SRC}
    git checkout reconstruct_experimental
    popd
fi

export LD_LIBRARY_PATH=$INSTALL_ROOT/gcc/lib64:$INSTALL_ROOT/silo/lib/:$INSTALL_ROOT/hdf5/lib:$LD_LIBRARY_PATH
export HDF5_ROOT=$INSTALL_ROOT/hdf5/

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_PREFIX_PATH=${INSTALL_ROOT}/hpx \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS -fpermissive" \
    -DCMAKE_EXE_LINKER_FLAGS="$LDCXXFLAGS -lz -L$INSTALL_ROOT/hdf5/lib -lhdf5" \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDCXXFLAGS" \
    -DBOOST_ROOT=$INSTALL_ROOT/boost \
    -DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
    -DOCTOTIGER_WITH_KOKKOS=$OCT_WITH_KOKKOS \
    -DOCTOTIGER_WITH_BLAST_TEST=OFF \
    -DOCTOTIGER_WITH_TESTS=OFF \
    -DOCTOTIGER_WITH_LEGACY_VC=OFF \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DVc_DIR=$INSTALL_ROOT/Vc/lib/cmake/Vc \
    -DBOOST_ROOT=$BOOST_ROOT \
    -DHPX_DIR=$INSTALL_ROOT/hpx/$LIBHPX/cmake/HPX/ \
    -DHDF5_INCLUDE_DIR=$INSTALL_ROOT/hdf5/include \
    -DSilo_INCLUDE_DIR=$INSTALL_ROOT/silo/include \
    -DSilo_LIBRARY=$INSTALL_ROOT/silo/lib/libsiloh5.a \
    -DSilo_DIR=$INSTALL_ROOT/silo \
    -DCPPuddle_DIR=$INSTALL_ROOT/cppuddle/build/cppuddle/lib/cmake/CPPuddle \
    -DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -ccbin $INSTALL_ROOT/gcc/bin -std=c++14" \
    -DKokkos_DIR=$INSTALL_ROOT/kokkos/install/lib/cmake/Kokkos \
    -DHPXKokkos_DIR=$INSTALL_ROOT/hpx-kokkos/install/lib/cmake/HPXKokkos \
    -DCMAKE_CXX_COMPILER="$INSTALL_ROOT/kokkos/install/bin/nvcc_wrapper"

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1

    #-DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -ccbin $INSTALL_ROOT/gcc/bin -std=c++14" \
    #-DCMAKE_CXX_COMPILER=$CXX \
