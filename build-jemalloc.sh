#!/usr/bin/env bash

set -ex

DIR_SRC=${SOURCE_ROOT}/jemalloc
#DIR_BUILD=${INSTALL_ROOT}/jemalloc/build
DIR_INSTALL=${INSTALL_ROOT}/jemalloc
FILE_MODULE=${INSTALL_ROOT}/modules/jemalloc/5.1.0

DOWNLOAD_URL="https://github.com/jemalloc/jemalloc/releases/download/5.1.0/jemalloc-5.1.0.tar.bz2"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- ${DOWNLOAD_URL} | tar xj --strip-components=1
        ./autogen.sh
        ./configure --prefix=${DIR_INSTALL}
        make -j${PARALLEL_BUILD}
        make install
    )
fi

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {jemalloc}
}
module-whatis {jemalloc}
set root    ${DIR_INSTALL}
conflict    jemalloc
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    PATH               \$root/sbin
prepend-path    MANPATH            \$root/share/man
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
prepend-path    PKG_CONFIG_PATH    \$root/lib/pkgconfig
setenv          JEMALLOC_ROOT      \$root
EOF

