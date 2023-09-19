#!/usr/bin/env bash

set -ex

: ${SOURCE_ROOT:?} ${INSTALL_ROOT:?} ${GCC_VERSION:?} ${HDF5_VERSION:?} ${SILO_VERSION:?}

DIR_SRC=${SOURCE_ROOT}/silo-4.10.2
#DIR_BUILD=${INSTALL_ROOT}/silo/build
DIR_INSTALL=${INSTALL_ROOT}/silo
FILE_MODULE=${INSTALL_ROOT}/modules/silo/${SILO_VERSION}

#DOWNLOAD_URL="https://wci.llnl.gov/sites/wci/files/2021-01/silo-${SILO_VERSION}-bsd.tgz"
DOWNLOAD_URL="https://github.com/LLNL/Silo/archive/refs/tags/4.10.2.tar.gz"


if [[ ! -d ${DIR_SRC} ]]; then
    (
        mkdir -p ${DIR_SRC}
        cd ${DIR_SRC}
        wget  ${DOWNLOAD_URL}
       	tar -xf ${SILO_VERSION}.tar.gz
	mv Silo-${SILO_VERSION}/* .
	rm -rf  Silo-${SILO_VERSION}
    )
fi

(
    cd ${DIR_SRC}
    #autoreconf -ifv
    sed -i 's/-lhdf5/$hdf5_lib\/libhdf5.a -ldl/g' configure
    ./configure --prefix=${DIR_INSTALL} --with-hdf5=$INSTALL_ROOT/hdf5/include,$INSTALL_ROOT/hdf5/lib --enable-optimization
    sed -i.bak -e '866d;867d' src/silo/Makefile

    make -j${PARALLEL_BUILD} install
)

mkdir -p $(dirname ${FILE_MODULE})
cat >${FILE_MODULE} <<EOF
#%Module
proc ModulesHelp { } {
  puts stderr {Silo}
}
module-whatis {Silo}
set root    ${DIR_INSTALL}
conflict    silo
module load gcc/${GCC_VERSION}
module load hdf5/${HDF5_VERSION}
prereq      gcc/${GCC_VERSION}
prereq      hdf5/${HDF5_VERSION}
prepend-path    CPATH              \$root/include
prepend-path    PATH               \$root/bin
prepend-path    LD_LIBRARY_PATH    \$root/lib
prepend-path    LIBRARY_PATH       \$root/lib
setenv          SILO_ROOT          \$root
setenv          SILO_DIR           \$root
EOF

