#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${JEMALLOC_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/otf2
#DIR_BUILD=${INSTALL_ROOT}/papi/build
DIR_INSTALL=${INSTALL_ROOT}/otf2
FILE_MODULE=${INSTALL_ROOT}/modules/otf2/${OTF2_VERSION}

DOWNLOAD_URL="https://www.vi-hps.org/cms/upload/packages/otf2/otf2-${OTF2_VERSION}.tar.gz"

if [[ ! -d ${DIR_INSTALL} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget ${DOWNLOAD_URL} 
        tar -xzf otf2-${OTF2_VERSION}.tar.gz
	cd otf2-${OTF2_VERSION}
        ./configure --prefix=${DIR_INSTALL} 
        make -j${PARALLEL_BUILD} 
        make install
    )
fi

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {otf2}
}
module-whatis {otf2}
set root    ${DIR_INSTALL}
conflict    otf2
module load gcc/${GCC_VERSION}
prereq      gcc/${GCC_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    PATH               \$root/sbin
prepend-path    MANPATH            \$root/share/man
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
prepend-path    PKG_CONFIG_PATH    \$root/lib/pkgconfig
setenv          OTF2_ROOT      \$root
setenv          OTF2_VERSION   ${OTF2_VERSION}
EOF

