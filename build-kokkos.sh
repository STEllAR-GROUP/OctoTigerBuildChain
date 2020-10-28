#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${LIBHPX:?} ${BUILD_TYPE:?} \
    ${CMAKE_VERSION:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${CUDA_SM:?} \
    ${BOOST_VERSION:?} ${BOOST_BUILD_TYPE:?} \
    ${JEMALLOC_VERSION:?} ${HWLOC_VERSION:?} ${VC_VERSION:?} ${HPX_VERSION:?} \
    ${OCT_WITH_PARCEL:?}

DIR_SRC=${SOURCE_ROOT}/kokkos
DIR_BUILD=${INSTALL_ROOT}/kokkos/build
DIR_INSTALL=${INSTALL_ROOT}/kokkos

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
	cd ..
	git clone https://github.com/kokkos/kokkos kokkos
	cd kokkos
	git checkout 1774165304d81ea2db3818b7020f6c71fbefac97
	git apply ../../nvcc_wrapper_for_octotiger.patch
	cd ..
    )
fi

${CMAKE_COMMAND} \
	-H${DIR_SRC} \
	-B${DIR_BUILD} \
	-DKokkos_ARCH_HSW=ON \
	-DKokkos_ENABLE_TESTS=OFF \
	-DKokkos_ENABLE_INTERNAL_FENCES=OFF \
       	-DKokkos_ENABLE_CUDA=${OCT_WITH_CUDA} \
	-DKokkos_ENABLE_CUDA_LAMBDA=ON \
        -DKokkos_ARCH_PASCAL61=${OCT_WITH_CUDA} \
       	-DKokkos_ENABLE_SERIAL=ON \
       	-DKokkos_ENABLE_HPX=ON \
        -DKokkos_ENABLE_HPX_ASYNC_DISPATCH=ON \
	-DHPX_DIR=$INSTALL_ROOT/hpx/$LIBHPX/cmake/HPX/ \
       	-DCMAKE_CXX_COMPILER=${SOURCE_ROOT}/kokkos/bin/nvcc_wrapper \
       	-DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/kokkos/install

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install

#	-DCMAKE_CXX_FLAGS="-isystem ${INSTALL_ROOT}/hpx/include" \
