#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CMAKE_COMMAND:?} ${BUILD_TYPE:?} ${OCT_WITH_CUDA:?} ${OCT_WITH_KOKKOS:?}

DIR_SRC=${SOURCE_ROOT}/cppuddle
DIR_BUILD=${INSTALL_ROOT}/cppuddle/build
DIR_INSTALL=${INSTALL_ROOT}/cppuddle/build
mkdir -p ${DIR_BUILD}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/SC-SGS/CPPuddle.git ${DIR_SRC}
    cd ${DIR_SRC}
    git checkout master
    cd -
fi

cd ${DIR_SRC}
git pull
cd -

${CMAKE_COMMAND} \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}/cppuddle \
    -DCPPUDDLE_WITH_TESTS=OFF \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCPPUDDLE_WITH_COUNTERS=OFF \
    -DCPPUDDLE_WITH_HPX=ON \
    -DCPPUDDLE_WITH_CUDA=${OCT_WITH_CUDA} \
    -DCPPUDDLE_WITH_KOKKOS=${OCT_WITH_KOKKOS} \
    -DHPX_DIR=$INSTALL_ROOT/hpx/${LIB_DIR_NAME}/cmake/HPX/ \
    -DKokkos_DIR=$INSTALL_ROOT/kokkos/install/${LIB_DIR_NAME}/cmake/Kokkos \
    -DHPXKokkos_DIR=$INSTALL_ROOT/hpx-kokkos/install/${LIB_DIR_NAME}/cmake/HPXKokkos

${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install
cp ${DIR_BUILD}/compile_commands.json ${DIR_SRC}/compile_commands.json

