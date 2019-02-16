#!/usr/bin/env bash

set -ex

DIR_SRC=${SOURCE_ROOT}/gcc
DIR_BUILD=${INSTALL_ROOT}/gcc/build
DIR_INSTALL=${INSTALL_ROOT}/gcc

DOWNLOAD_URL="https://ftp.gnu.org/gnu/gcc/gcc-${USED_GCC_VERSION}/gcc-${USED_GCC_VERSION}.tar.xz"
#DOWNLOAD_URL="https://bigsearcher.com/mirrors/gcc/releases/gcc-${USED_GCC_VERSION}/gcc-${USED_GCC_VERSION}.tar.gz"
#DOWNLOAD_URL="ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-$USED_GCC_VERSION/gcc-$USED_GCC_VERSION.tar.xz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- "${DOWNLOAD_URL}" | tar xJ --strip-components=1
        ./contrib/download_prerequisites
    )
fi

(
    mkdir -p ${DIR_BUILD}
    cd ${DIR_BUILD}
    ${DIR_SRC}/configure --prefix=${DIR_INSTALL} --enable-languages=c,c++,fortran --disable-multilib --disable-nls
    make -j${PARALLEL_BUILD}
    make install
)

