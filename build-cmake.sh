#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/cmake
DIR_BUILD=${INSTALL_ROOT}/cmake/build
DIR_INSTALL==${INSTALL_ROOT}/cmake

DOWNLOAD_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}}
        curl -JL ${DOWNLOAD_URL} | tar xz --strip-components=1
    )
fi

mkdir -p ${DIR_BUILD}
(
    cd ${DIR_BUILD}
    ${DIR_SRC}/bootstrap --parallel=${PARALLEL_BUILD} --prefix=$${DIR_INSTALL}
    make -j${PARALLEL_BUILD} install
)

