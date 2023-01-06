#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${CMAKE_COMMAND:?} ${BUILD_TYPE:?}

DIR_SRC=${SOURCE_ROOT}/cppuddle
DIR_BUILD=${INSTALL_ROOT}/cppuddle/build
DIR_INSTALL=${INSTALL_ROOT}/cppuddle/build
mkdir -p ${DIR_BUILD}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone https://github.com/SC-SGS/CPPuddle.git ${DIR_SRC}
    cd ${DIR_SRC}
    git checkout add_sycl
    cd ..
fi

cd ${DIR_SRC}
git pull
cd -

${CMAKE_COMMAND} -H${DIR_SRC} -B${DIR_BUILD} -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL}/cppuddle -DCPPUDDLE_WITH_TESTS=OFF -DCPPUDDLE_WITH_COUNTERS=OFF -DCPPUDDLE_WITH_MULTIGPU_SUPPORT=OFF  -DHPX_DIR=$INSTALL_ROOT/hpx/${LIB_DIR_NAME}/cmake/HPX/ -DCPPUDDLE_WITH_HPX=OFF -DCPPUDDLE_WITH_HPX_MUTEX=OFF
${CMAKE_COMMAND} --build ${DIR_BUILD} -- -j${PARALLEL_BUILD} VERBOSE=1
${CMAKE_COMMAND} --build ${DIR_BUILD} --target install
cp ${DIR_BUILD}/compile_commands.json ${DIR_SRC}/compile_commands.json

