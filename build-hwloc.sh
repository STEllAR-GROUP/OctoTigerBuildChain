#!/usr/bin/env bash

set -ex

DIR_SRC=${SOURCE_ROOT}/hwloc
DIR_BUILD=${INSTALL_ROOT}/hwloc/build
DIR_INSTALL=${INSTALL_ROOT}/hwloc
FILE_MODULE=${INSTALL_ROOT}/modules/hwloc/1.11.12

DOWNLOAD_URL="https://download.open-mpi.org/release/hwloc/v1.11/hwloc-1.11.12.tar.gz"

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- ${DOWNLOAD_URL} | tar xz --strip-components=1
    )
fi

(
    mkdir -p ${DIR_BUILD}
    cd ${DIR_BUILD}
    ${DIR_SRC}/configure --prefix=${DIR_INSTALL} --disable-opencl 
    make -j ${PARALLEL_BUILD}
    make install
)

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {hwloc}
}
module-whatis {hwloc}
set root    ${DIR_INSTALL}
conflict    hwloc
prereq      gcc/${USED_GCC_VERSION}
prepend-path    CPATH           \$root/include
prepend-path    PATH            \$root/bin
prepend-path    LD_LIBRARY_PATH \$root/lib
prepend-path    LIBRARY_PATH    \$root/lib
setenv HWLOC_ROOT               \$root
EOF

