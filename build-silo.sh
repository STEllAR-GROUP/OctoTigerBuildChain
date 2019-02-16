#!/usr/bin/env bash

DIR_SRC=${SOURCE_ROOT}/silo
#DIR_BUILD=${INSTALL_ROOT}/silo/build
DIR_INSTALL==${INSTALL_ROOT}/silo

DOWNLOAD_URL="http://phys.lsu.edu/~dmarcel/silo-4.10.2.tar.gz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        curl -JL ${DOWNLOAD_URL} | tar xz --strip-components=1
    )
fi

(
    cd ${DIR_SRC}
    sed -i 's/-lhdf5/$hdf5_lib\/libhdf5.a -ldl/g' configure
    autoreconf -ifv
    ./configure --prefix=${DIR_INSTALL} --with-hdf5=$INSTALL_ROOT/hdf5/include,$INSTALL_ROOT/hdf5/lib/ --enable-optimization

    make -j${PARALLEL_BUILD} install
)

