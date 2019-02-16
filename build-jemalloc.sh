#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/jemalloc
DIR_BUILD=${INSTALL_ROOT}/jemalloc/build
DIR_INSTALL=${INSTALL_ROOT}/jemalloc

DOWNLOAD_URL="https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2"

if [[ ! -d ${DIR_SRC} ]]; then
    mkdir -p ${DIR_SRC}
    cd ${DIR_SRC}
    wget -O- ${DOWNLOAD_URL} | tar xJ --strip-components=1
fi

(
    cd ${DIR_BUILD}
    ${DIR_SRC}/autogen.sh
    ${DIR_SRC}/configure --prefix=${DIR_INSTALL}
    make -j${PARALLEL_BUILD}
    make install
)
