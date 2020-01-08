#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${JEMALLOC_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/papi
#DIR_BUILD=${INSTALL_ROOT}/papi/build
DIR_INSTALL=${INSTALL_ROOT}/papi
FILE_MODULE=${INSTALL_ROOT}/modules/papi/${PAPI_VERSION}

DOWNLOAD_URL="http://icl.utk.edu/projects/papi/downloads/papi-${PAPI_VERSION}.tar.gz"

if [[ ! -d ${DIR_INSTALL} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget ${DOWNLOAD_URL} 
        tar -xzf papi-${PAPI_VERSION}.tar.gz
	cd papi-${PAPI_VERSION}/src
        ./configure --prefix=${DIR_INSTALL} --enable-shared
        make -j${PARALLEL_BUILD} 
        make install
    )
fi

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {papi}
}
module-whatis {papi}
set root    ${DIR_INSTALL}
conflict    papi
module load gcc/${GCC_VERSION}
prereq      gcc/${GCC_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    PATH               \$root/sbin
prepend-path    MANPATH            \$root/share/man
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
prepend-path    PKG_CONFIG_PATH    \$root/lib/pkgconfig
setenv          PAPI_ROOT      \$root
setenv          PAPI_VERSION   ${PAPI_VERSION}
EOF

