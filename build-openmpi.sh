#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${OPENMPI_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/openmpi
DIR_BUILD=${INSTALL_ROOT}/openmpi/build
DIR_INSTALL=${INSTALL_ROOT}/openmpi
FILE_MODULE=${INSTALL_ROOT}/modules/openmpi/${OPENMPI_VERSION}

get_download_url()
{
    echo "https://download.open-mpi.org/release/open-mpi/v${OPENMPI_VERSION::-2}/openmpi-${OPENMPI_VERSION}.tar.gz"
}

if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget -O- $(get_download_url) | tar xz --strip-components=1
    )
fi

(
    unset HWLOC_VERSION

    mkdir -p ${DIR_BUILD}
    cd ${DIR_BUILD}

    ${DIR_SRC}/configure --prefix=${DIR_INSTALL} 
    make -j${PARALLEL_BUILD}
    make install
)

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
puts stderr {openmpi}
}

module-whatis {openmpi}
set root ${DIR_INSTALL}
conflict openmpi
module load gcc/${GCC_VERSION}
prereq gcc/${GCC_VERSION}

prepend-path CPATH           \$root/include
prepend-path LD_LIBRARY_PATH \$root/lib
prepend-path LIBRARY_PATH    \$root/lib
prepend-path MANPATH         \$root/share/man
prepend-path PATH            \$root/bin
prepend-path PKG_CONFIG_PATH \$root/lib/pkgconfig
EOF

