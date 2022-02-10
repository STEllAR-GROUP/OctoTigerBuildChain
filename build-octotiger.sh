#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${OCT_WITH_KOKKOS:?} \
    ${LIB_DIR_NAME:?} ${OCT_WITH_MONOPOLE_HPX_EXECUTOR:?} ${OCT_WITH_MULTIPOLE_HPX_EXECUTOR:?} \
    ${OCT_WITH_KOKKOS_SCALAR:?} ${CUDA_SM:?} ${OCT_ARCH_FLAGS:?}


DIR_SRC=${SOURCE_ROOT}/octotiger
DIR_BUILD=${INSTALL_ROOT}/octotiger/build
#DIR_INSTALL=${INSTALL_ROOT}/octotiger

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/STEllAR-GROUP/octotiger.git ${DIR_SRC}
    pushd ${DIR_SRC}
    #git checkout ookami_arm_fixes
    git checkout  d33c144e0905cce8dcbd3a1acdfb447f72a3dc2c
    git submodule update --init --recursive
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
    -DCMAKE_CUDA_COMPILE_SEPARABLE_COMPILATION=ON \
    -DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
    -DOCTOTIGER_WITH_KOKKOS=$OCT_WITH_KOKKOS \
    -DOCTOTIGER_WITH_BLAST_TEST=OFF \
    -DOCTOTIGER_WITH_TESTS=ON \
    -DOCTOTIGER_WITH_Vc=ON \
    -DOCTOTIGER_WITH_LEGACY_VC=OFF \
    -DOCTOTIGER_WITH_GRIDDIM=8 \
    -DOCTOTIGER_WITH_MAX_NUMBER_FIELDS=15 \
    -DOCTOTIGER_WITH_MONOPOLE_HOST_HPX_EXECUTOR=${OCT_WITH_MONOPOLE_HPX_EXECUTOR} \
    -DOCTOTIGER_WITH_MULTIPOLE_HOST_HPX_EXECUTOR=${OCT_WITH_MULTIPOLE_HPX_EXECUTOR} \
    -DOCTOTIGER_SIMD_EXTENSION=NEON \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    -DVc_DIR=$INSTALL_ROOT/Vc/lib/cmake/Vc \
    -DHPX_DIR=$INSTALL_ROOT/hpx/$LIBHPX/cmake/HPX/ \
    -DHDF5_INCLUDE_DIR=$INSTALL_ROOT/hdf5/include \
    -DSilo_INCLUDE_DIR=$INSTALL_ROOT/silo/include \
    -DSilo_LIBRARY=$INSTALL_ROOT/silo/lib/libsiloh5.a \
    -DSilo_DIR=$INSTALL_ROOT/silo \
    -DCMAKE_CUDA_FLAGS="-arch=${CUDA_SM} ${OCT_CUDA_INTERNAL_COMPILER} " \
    -DOCTOTIGER_WITH_FAST_FP_CONTRACT=ON \
    -DOCTOTIGER_CUDA_ARCH=${CUDA_SM} \
    -DOCTOTIGER_ARCH_FLAG=${OCT_ARCH_FLAGS} \
    -DCPPuddle_DIR=$INSTALL_ROOT/cppuddle/build/cppuddle/lib/cmake/CPPuddle \
    -DKokkos_DIR=$INSTALL_ROOT/kokkos/install/${LIB_DIR_NAME}/cmake/Kokkos \
    -DHPXKokkos_DIR=$INSTALL_ROOT/hpx-kokkos/install/${LIB_DIR_NAME}/cmake/HPXKokkos

# SVE patch
cd build/octotiger/build/_deps/kokkossimd-src
if [[ $(git diff --stat) != '' ]]; then
  echo 'Kokkos simd directory is dirty -> SVE patch already applied'
else
  echo 'Kokkos simd directory is clean -> we need to apply the SVE patch'
  git apply ../../../../../kokkos-simd-ookami.patch
fi
cd -

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1

    #-DOCTOTIGER_WITH_FORCE_SCALAR_KOKKOS_SIMD=${OCT_WITH_KOKKOS_SCALAR} \
    #-DCMAKE_CXX_COMPILER="${OCT_CMAKE_CXX_COMPILER}" 
    #-DCMAKE_CUDA_FLAGS="-arch=$CUDA_SM -ccbin $INSTALL_ROOT/gcc/bin -std=c++14" \
    #-DCMAKE_CXX_COMPILER=$CXX \
    #-DOCTOTIGER_WITH_CUDA=$OCT_WITH_CUDA \
