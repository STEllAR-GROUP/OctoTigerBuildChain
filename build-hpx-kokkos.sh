#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${LIB_DIR_NAME:?} ${BUILD_TYPE:?} \
    ${CMAKE_VERSION:?} ${CMAKE_COMMAND:?} ${OCT_WITH_CUDA:?} ${CUDA_SM:?} \
    ${BOOST_VERSION:?} ${BOOST_BUILD_TYPE:?} \
    ${JEMALLOC_VERSION:?} ${HWLOC_VERSION:?} ${VC_VERSION:?} ${HPX_KOKKOS_VERSION:?} \
    ${OCT_WITH_PARCEL:?}

DIR_SRC=${SOURCE_ROOT}/hpx-kokkos
DIR_BUILD=${INSTALL_ROOT}/hpx-kokkos/build
DIR_INSTALL=${INSTALL_ROOT}/hpx-kokkos

rm -rf "${DIR_SRC}"
if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
	cd ..
	git clone https://github.com/STEllAR-GROUP/hpx-kokkos.git hpx-kokkos
	cd hpx-kokkos
	git checkout ${HPX_KOKKOS_VERSION}
	cd ..
fi

mkdir -p "$DIR_BUILD"
# use either event or callback for the future type
# octotiger will use this to enable the event polling if required
${CMAKE_COMMAND} \
	-H${DIR_SRC} \
	-B${DIR_BUILD} \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DHPX_KOKKOS_CUDA_FUTURE_TYPE=${HPX_KOKKOS_FUTURE_TYPE} \
	-DKokkos_DIR=$INSTALL_ROOT/kokkos/install/${LIB_DIR_NAME}/cmake/Kokkos/ \
	-DHPX_DIR=$INSTALL_ROOT/hpx/${LIB_DIR_NAME}/cmake/HPX/ \
       	-DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT}/hpx-kokkos/install

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install
