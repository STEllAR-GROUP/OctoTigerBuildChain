#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${BUILD_TYPE:?} \
    ${CMAKE_VERSION:?} ${CMAKE_COMMAND:?} ${VC_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/Vc
DIR_BUILD=${INSTALL_ROOT}/Vc/build
DIR_INSTALL=${INSTALL_ROOT}/Vc
FILE_MODULE=${INSTALL_ROOT}/modules/Vc/${VC_VERSION}-${BUILD_TYPE}

if [[ ! -d ${DIR_SRC} ]]; then
    git clone --branch=1.4.1 --depth=1 https://github.com/VcDevel/Vc.git ${DIR_SRC}
    (
        cd ${DIR_SRC}
        git submodule update --init
    )
fi

${CMAKE_COMMAND} \
    -Wno-dev \
    -H${DIR_SRC} \
    -B${DIR_BUILD} \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_INSTALL_PREFIX=${DIR_INSTALL} \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF

${CMAKE_COMMAND} --build ${DIR_BUILD} --target install -- -j${PARALLEL_BUILD} VERBOSE=1
cp ${DIR_BUILD}/compile_commands.json ${DIR_SRC}/compile_commands.json

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {Vc}
}
module-whatis {Vc}
set root    ${DIR_INSTALL}
conflict    Vc
prereq      gcc/${GCC_VERSION}
prereq      cmake/${CMAKE_VERSION}
prepend-path    CPATH                 \$root/include
prepend-path    CPLUS_INCLUDE_PATH    \$root/include
prepend-path    PATH                  \$root/bin
prepend-path    LD_LIBRARY_PATH       \$root/lib
setenv          Vc_ROOT               \$root
setenv          Vc_DIR                \$root/lib/cmake/Vc
EOF

