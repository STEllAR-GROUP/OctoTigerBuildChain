#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${JEMALLOC_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/libfabric
#DIR_BUILD=${INSTALL_ROOT}/libfabric/build
DIR_INSTALL=${INSTALL_ROOT}/libfabric
FILE_MODULE=${INSTALL_ROOT}/modules/libfabric/${LIBFABRIC_VERSION}

DOWNLOAD_URL="https://github.com/ofiwg/libfabric/archive/v${LIBFABRIC_VERSION}.tar.gz"

if [[ ! -d ${DIR_INSTALL} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget ${DOWNLOAD_URL}
        tar -xf v${LIBFABRIC_VERSION}.tar.gz
	cd libfabric-${LIBFABRIC_VERSION}
        ./autogen.sh	
        ./configure --disable-verbs --disable-sockets --disable-usnic --disable-udp --disable-rxm --disable-rxd --disable-shm --disable-mrail --disable-tcp --enable-gni --prefix=$INSTALL_ROOT/libfabric --no-recursion
        make -j${PARALLEL_BUILD}
        make install
    )
fi

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {libfabric}
}
module-whatis {libfabric}
set root    ${DIR_INSTALL}
conflict    libfabric
module load gcc/${GCC_VERSION}
prereq      gcc/${GCC_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    PATH               \$root/sbin
prepend-path    MANPATH            \$root/share/man
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
prepend-path    PKG_CONFIG_PATH    \$root/lib/pkgconfig
setenv          LIBFABRIC_ROOT      \$root
setenv          LIBFABRIC_VERSION   ${LIBFABRIC_VERSION}
EOF

