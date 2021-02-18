#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CMAKE_COMMAND:?} ${BUILD_TYPE:?}

DIR_SRC=${SOURCE_ROOT}/cppuddle
DIR_BUILD=${INSTALL_ROOT}/cppuddle/build
DIR_INSTALL=${INSTALL_ROOT}/cppuddle/build
mkdir -p ${DIR_BUILD}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/G-071/hpx-kokkos-interopt-WIP.git ${DIR_SRC}
fi

#export LD_LIBRARY_PATH=$INSTALL_ROOT/gcc/lib64:$INSTALL_ROOT/silo/lib/

${CMAKE_COMMAND} -H${DIR_SRC} -B${DIR_BUILD} -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}/cppuddle -DCPPUDDLE_WITH_TESTS=OFF -DCPPUDDLE_WITH_COUNTERS=OFF
${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install

