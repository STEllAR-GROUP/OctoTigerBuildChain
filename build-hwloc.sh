#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/hwloc
DIR_BUILD=${INSTALL_ROOT}/hwloc/build
DIR_INSTALL==${INSTALL_ROOT}/hwloc

DOWNLOAD_URL="https://download.open-mpi.org/release/hwloc/v1.11/hwloc-1.11.12.tar.gz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        curl -JL ${DOWNLOAD_URL} tar xz --strip-components=1
    )
fi

(
    cd ${DIR_BUILD}
    ${DIR_SRC}/configure --prefix=${DIR_INSTALL} --disable-opencl 
    make -j ${PARALLEL_BUILD}
    make install
)

